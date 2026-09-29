// Reyvit Framework — G2 UX/UI & SEO
// Patrón real usado en los proyectos: head() por ruta en TanStack Start.
// Cada página define su propio título, descripción, canónica y JSON-LD.
// Sanitizado: dominio de ejemplo, sin datos de clientes.

const SITE_URL = "https://example.com";

interface SeoInput {
  title: string;
  description: string;
  path: string;
  jsonLd?: Record<string, unknown>;
}

export function buildHead({ title, description, path, jsonLd }: SeoInput) {
  const canonical = `${SITE_URL}${path}`;
  return {
    meta: [
      { title },
      { name: "description", content: description },
      { property: "og:type", content: "website" },
      { property: "og:title", content: title },
      { property: "og:description", content: description },
      { property: "og:url", content: canonical },
      { name: "twitter:card", content: "summary_large_image" },
    ],
    links: [{ rel: "canonical", href: canonical }],
    scripts: jsonLd
      ? [{ type: "application/ld+json", children: JSON.stringify(jsonLd) }]
      : [],
  };
}

// Ejemplo de uso en una ruta de servicio local (SEO local peruano):
export const head = () =>
  buildHead({
    title: "Servicio en Lima | Marca",
    description:
      "Descripción única de la página, orientada a la intención de búsqueda local.",
    path: "/servicios/lima",
    jsonLd: {
      "@context": "https://schema.org",
      "@type": "LocalBusiness",
      name: "Marca",
      areaServed: "Lima, Perú",
      telephone: "+51 900000000",
    },
  });
