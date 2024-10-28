import getLog from "@/util/log";
import * as fs from "fs/promises";
import * as path from "path";

export const command = "init";
export const describe = "Initializes the project, downloading necessary data and preparing for output.";
export const builder = {
    "skip-changes": {
        type: "boolean",
        default: false,
        describe: "Skip downloading the PSGC summary of changes. This may cause out-of-date maps to be generated."
    },
    "parallel-streams": {
        type: "number",
        default: 3,
        describe: "Number of parallel streams to use when downloading files."
    },
    "hdx-api-base": {
        type: "string",
        default: "https://data.humdata.org/api/",
        describe: "Base URL for the HDX API. API version 3 is always used."
    },
    "hdx-dataset-id": {
        type: "string",
        default: "cod-ab-phl",
        describe: "ID of the dataset to download from HDX. Should point to the Philippine Administrative Boundaries COD dataset."
    }
};

export async function handler(argv: any) {
    const { downloadFile } = await import("ipull");

    const dataPath = path.join( process.cwd(), "data" );
    const log = getLog(argv);
    log.trace(argv);

    await fs.mkdir( dataPath, { recursive: true } );

    log.info( "Downloading shapefiles..." );

    log.debug("Getting active data from OCHA HDX API...");

    // This is a CKAN REST API endpoint. But for the sake of simplicity, we'll make a direct request instead of
    // relying on an abstraction which lets us navigate the CKAN API programatically.
    const hdxDataUrl = new URL("3/action/package_show", argv["hdx-api-base"].replace(/\/*$/, "") + "/");
    hdxDataUrl.searchParams.append("id", argv["hdx-dataset-id"]);

    log.trace("HTTP GET:", hdxDataUrl.toString());
    const hdxDataResponse = await fetch( hdxDataUrl.toString() );
    log.trace(hdxDataResponse.status, hdxDataResponse.statusText);

    const hdxDataJson = await hdxDataResponse.json();
    if (!hdxDataJson.success) {
        log.error("Failed to get dataset information:", hdxDataJson.error);
        return;
    }

    const hdxResources = hdxDataJson.result.resources;
    const shapefileResources = hdxResources.filter(
        (r: any) =>
            /^phl_adm_psa_namria_\d+_SHP\.zip$/gi.test(r.name) ||
            /Philippines administrative level [\d-]+ shapefiles/i.test(r.description)
    );

    if (shapefileResources.length === 0) {
        log.error("No shapefiles found in dataset.");
        log.info("Please file a bug report at https://github.com/ChlodAlejandro/philippine-adm-maps")
        return;
    }

    log.debug(`Found ${shapefileResources.length.toLocaleString()} shapefile ZIPs to download.`);
    shapefileResources.forEach((r: any) => log.trace(`* ${r.name}`))

    for (const resource of shapefileResources) {
        const resourceUrl = new URL(resource.download_url);
        const resourceFilename = path.basename( resourceUrl.pathname );

        log.debug("Downloading", resourceFilename, "from", resourceUrl.toString());

        // noinspection JSUnusedGlobalSymbols
        try {
            const shapefileZipDownloader = await downloadFile({
                url: resourceUrl.toString(),
                cliProgress: true,
                directory: dataPath,
                parallelStreams: argv["parallel-streams"],
                retryOnServerError: true,
                skipExisting: true,
                // https://github.com/ido-pluto/ipull/issues/12
                defaultFetchDownloadInfo: {
                    length: resource.size,
                    acceptRange: true
                }
            });
            await shapefileZipDownloader.download();
        } catch (e) {
            log.error("Failed to download", resourceFilename, e);
            return;
        }

        log.debug("Downloaded", resourceFilename);
    }

    if (!argv["skip-changes"]) {
        log.info( "Downloading Philippine Standard Geographic Code summary of changes..." );

        log.debug("Getting current summary of changes URL...");

        const psgcHomepageUrl = new URL("https://psa.gov.ph/classification/psgc/");
        log.trace("HTTP GET:", psgcHomepageUrl.toString());
        const psgcHomepageResponse = await fetch( psgcHomepageUrl.toString() );
        log.trace(psgcHomepageResponse.status, psgcHomepageResponse.statusText);

        const psgcHomepageHtml = await psgcHomepageResponse.text();
        const psgcChangesMatch =
            // List of changes from the current active post on /classification/psgc
            psgcHomepageHtml.match(/<a href="([^"]+)"[^>]*>PSGC [\dQH]+ \d+ Summary of Changes<\/a>/i) ??
            // List of changes from the website sidebar
            psgcHomepageHtml.match(/<a href="([^"]+)"[^>]*>Summary of Changes<\/a>/i);

        if (!psgcChangesMatch) {
            log.error("Failed to find summary of changes URL.");
            log.info("Please file a bug report at https://github.com/ChlodAlejandro/philippine-adm-maps");
            log.warn("Download will continue, but the generated maps may be out-of-date.");
            log.warn("Run this command again to try re-downloading the summary of changes.");
        }

        const psgcChangesUrlString = psgcChangesMatch[1];
        const psgcChangesUrl = new URL(psgcChangesUrlString, psgcHomepageUrl);

        const originalChangesFilename = psgcChangesUrl.pathname.split("/").pop();
        const finalChangesFilename = "psgc_changes.xlsx";
        log.debug("Downloading", originalChangesFilename, "from", psgcChangesUrl.toString());

        try {
            const psgcChangesDownloader = await downloadFile({
                url: psgcChangesUrl.toString(),
                cliProgress: true,
                savePath: path.join(dataPath, finalChangesFilename),
                parallelStreams: argv["parallel-streams"],
                retryOnServerError: true,
                skipExisting: true
            });
            await psgcChangesDownloader.download();
        } catch (e) {
            log.error("Failed to download", originalChangesFilename, e);
            return;
        }

        log.debug("Downloaded", originalChangesFilename, `as "${finalChangesFilename}"`);
    }

    log.info("Initialization complete!");
}
