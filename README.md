# Philippine Metadata SVGs
This repository contains files used to generate SVGs of Philippine municipalities and provinces with relevant metadata. This includes the name of the province and municipality, their [Philippine Standard Geographic Codes](https://psa.gov.ph/classification/psgc/), and their Wikidata entity ID (Q ID), if available.

This project makes use of [Node.js](https://nodejs.org/). Install it if you haven't already.

## Datasets
Data comes is downloaded from the [United Nations Office for the Coordination of Humanitarian Affairs](https://en.wikipedia.org/wiki/United_Nations_Office_for_the_Coordination_of_Humanitarian_Affairs) [Humanitarian Data Exchange](https://data.humdata.org/). This downloaded data is compiled from the Philippine [National Mapping and Resource Information Authority](https://en.wikipedia.org/wiki/National_Mapping_and_Resource_Information_Authority) (NAMRIA) and the [Philippine Statistics Authority](https://en.wikipedia.org/wiki/Philippine_Statistics_Authority) (PSA), in the absence of official boundaries. More information about the shapefiles can be found at https://data.humdata.org/dataset/cod-ab-phl.

## Usage
1. Download dependencies first.
   ```bash
   npm install
   ```
2. Download the shapefiles.
   ```bash
   npm run download
   ```
3. Generate SVGs.
   ```bash
   # Generate an SVG with only 10% of points remaining.
   npm run gen-percent 10%
   # Generate an SVG fitting an output resolution 1000x800.
   npm run gen-resolution 1000x800
   # Generate an SVG but remove all islands
   npm run gen -filter-islands
   ```

## Prebuilt
Prebuilt images are available on this repository's [Actions](https://github.com/ChlodAlejandro/ph-metadata-svgs/actions). Images are current prebuilt for the following:
* Wikimedia Commons
   * [simplified 10%](https://commons.wikimedia.org/wiki/File:Municipalities_of_the_Philippines.svg)
   * [simplified 12329x16537](https://commons.wikimedia.org/wiki/File:Municipalities_of_the_Philippines_(simplified).svg)

## License
The tools in this project are licensed under the Apache License 2.0. Images produced by the tools in this project are not covered by the license.

Official works created by an employee or by multiple employees of the Government of the Philippines is subject to Part IV, Chapter I, Section 171.11 and Part IV, Chapter IV, Section 176 of Republic Act No. 8293 and Republic Act No. 10372, as amended, and is under Public Domain.

The website of the United Nations Office for the Coordination of Humanitarian Affairs (OCHA) which provides a download to shapefile data is [not under a free and open-source license](https://www.un.org/en/about-us/copyright).