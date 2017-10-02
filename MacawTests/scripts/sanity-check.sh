#!/bin/sh

ORIGINAL_DATASET="original-dataset"
PROCESSED_DATASET="processed-dataset"
MACAW_SERIALIZER_OUTPUT="macaw-serializer-output"
DIFF_FOLDER="diff"
MACAW_PNGS="macaw-pngs"
REFERENCE_PNG="refpng"

if [ ! -d "${ORIGINAL_DATASET}" ]; then
	echo "[FAILED] Could not find original dataset folder: '${ORIGINAL_DATASET}'. See README file where to get the original dataset from."
	exit 1
else
	echo "[OK] Found original dataset."
fi

if [ ! -d "${PROCESSED_DATASET}" ]; then
	echo "[FAILED] Could not find processed dataset folder: '${ORIGINAL_DATASET}'. See README file on how to create processed dataset."
	exit 1
else
	echo "[OK] Found processed dataset."
fi

if [ ! -d "${MACAW_SERIALIZER_OUTPUT}" ]; then
	echo "[INFO] Could not find ${MACAW_SERIALIZER_OUTPUT} folder, creating..."
	mkdir -p ${MACAW_SERIALIZER_OUTPUT}
else
	echo "[OK] Found Macaw serializer output folder."
fi

if [ ! -d "${DIFF_FOLDER}" ]; then
	echo "[INFO] Could not find ${DIFF_FOLDER} folder, creating..."
	mkdir -p ${DIFF_FOLDER}
else
	echo "[OK] Found diff folder."
fi

if [ ! -d "${MACAW_PNGS}" ]; then
	echo "[INFO] Could not find ${MACAW_PNGS} folder, creating..."
	mkdir -p ${MACAW_PNGS}
else
	echo "[OK] Found macaw PNGs output folder."
fi

if [ ! -d "${REFERENCE_PNG}" ]; then
	echo "[INFO] Could not find ${REFERENCE_PNG} folder, creating..."
	mkdir -p ${REFERENCE_PNG}
else
	echo "[OK] Found reference PNGs folder."
fi

echo "[OK] Sanity check passed." 
