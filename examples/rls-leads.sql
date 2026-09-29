-- Reyvit Framework — G3 Backend/Datos
-- Patrón real usado en los proyectos: tabla de leads con RLS en Supabase (PostgreSQL).
-- Sanitizado: sin nombres de clientes, sin claves, sin datos reales.

-- 1. Tabla de leads (el lead se guarda ANTES de redirigir a WhatsApp)
create table public.leads (
    id uuid primary key default gen_random_uuid(),
    nombre text not null,
    telefono text not null, -- formato +51 9XXXXXXXX
    mensaje text,
    origen text not null default 'web',
    estado text not null default 'nuevo', -- nuevo | contactado | cerrado | descartado
    consentimiento boolean not null default false, -- Ley 29733 (Perú)
    created_at timestamptz not null default now()
);

-- 2. Grants: la API de datos no hereda permisos por defecto
grant select, insert on public.leads to anon;
grant select, insert, update, delete on public.leads to authenticated;
grant all on public.leads to service_role;

-- 3. RLS: el público solo puede insertar; leer/actualizar requiere sesión
alter table public.leads enable row level security;

create policy "Cualquiera puede dejar un lead"
on public.leads for insert to anon
with check (consentimiento = true);

create policy "Solo el equipo lee los leads"
on public.leads for select to authenticated
using (true);

create policy "Solo el equipo actualiza estados"
on public.leads for update to authenticated
using (true);

-- 4. Índices para el embudo comercial
create index leads_estado_idx on public.leads (estado);
create index leads_created_idx on public.leads (created_at desc);

-- 5. Trigger de auditoría: quién cambió el estado y cuándo
create table public.leads_audit (
    id bigint generated always as identity primary key,
    lead_id uuid not null references public.leads (id) on delete cascade,
    estado_anterior text,
    estado_nuevo text,
    cambiado_por uuid,
    created_at timestamptz not null default now()
);

grant select, insert on public.leads_audit to authenticated;
grant all on public.leads_audit to service_role;

alter table public.leads_audit enable row level security;

create policy "Solo el equipo lee la auditoría"
on public.leads_audit for select to authenticated
using (true);

create or replace function public.registrar_cambio_estado()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    if old.estado is distinct from new.estado then
        insert into public.leads_audit (lead_id, estado_anterior, estado_nuevo, cambiado_por)
        values (new.id, old.estado, new.estado, auth.uid());
    end if;
    return new;
end;
$$;

create trigger leads_estado_audit
after update on public.leads
for each row execute function public.registrar_cambio_estado();
