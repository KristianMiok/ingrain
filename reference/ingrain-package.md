# ingrain: Resolution-Relative Audit of Positional Uncertainty for Occurrence Records

Classifies species occurrence records into four states relative to a
chosen analysis grain (the raster cell edge length): 'inert' (positional
uncertainty at or below half the grain, so uncertainty-aware corrections
cannot act), 'marginal' (uncertainty between half the grain and three
times the grain), 'actionable' (uncertainty above three times the grain,
where the choice of correction method has consequences), and
'unreported' (no uncertainty radius given, so no correction can act).
Provides per-dataset summaries and visualisations for auditing 'GBIF'
downloads before species distribution modelling.

## See also

Useful links:

- <https://kristianmiok.github.io/ingrain>

- <https://github.com/KristianMiok/ingrain>

- Report bugs at <https://github.com/KristianMiok/ingrain/issues>

## Author

**Maintainer**: Kristian Miok <kristianmiok.personal@gmail.com>
([ORCID](https://orcid.org/0009-0009-7380-9525))
