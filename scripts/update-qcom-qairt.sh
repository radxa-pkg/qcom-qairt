#!/bin/bash

set -e

QAIRT_VERSION=2.42.0.251225
QAIRT_FILE="v$QAIRT_VERSION.zip"
UNZIP_OUTPUT_DIR="qairt"
PLARFORM_DIR="aarch64-oe-linux-gcc11.2"

if [[ ! -f "$QAIRT_FILE" ]];
then
    curl -fsSL -o "$QAIRT_FILE" "https://softwarecenter.qualcomm.com/api/download/software/sdks/Qualcomm_AI_Runtime_Community/All/$QAIRT_VERSION/$QAIRT_FILE"
fi

if [[ ! -d "$UNZIP_OUTPUT_DIR/$QAIRT_VERSION" ]];
then
    unzip "$QAIRT_FILE"
    mv "$UNZIP_OUTPUT_DIR/$QAIRT_VERSION"/* "$UNZIP_OUTPUT_DIR"
fi

function COPY_GENIE_SDK {
    local version="$1"
    local QCOM_GENIE_SDK="qcom-genie-sdk-v${version}"
    mkdir -p "$QCOM_GENIE_SDK/usr/bin"
    mkdir -p "$QCOM_GENIE_SDK/usr/lib/aarch64-linux-gnu"
    mkdir -p "$QCOM_GENIE_SDK/usr/share/doc/$QCOM_GENIE_SDK"

    # Binaries
    install -m 0755 "$UNZIP_OUTPUT_DIR/bin/$PLARFORM_DIR/"genie* "$QCOM_GENIE_SDK/usr/bin/"

    # Libraries
    install -m 0755 "$UNZIP_OUTPUT_DIR/lib/$PLARFORM_DIR/libGenie.so" "$QCOM_GENIE_SDK/usr/lib/aarch64-linux-gnu/"

    # License
    install -m 0644 "$UNZIP_OUTPUT_DIR/LICENSE.pdf" "$QCOM_GENIE_SDK/usr/share/doc/$QCOM_GENIE_SDK/"
}

function COPY_QNN_SDK {
    local version="$1"
    local QCOM_QNN_SDK="qcom-qnn-sdk-v${version}"
    mkdir -p "$QCOM_QNN_SDK/usr/bin"
    mkdir -p "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu"
    mkdir -p "$QCOM_QNN_SDK/usr/share/doc/$QCOM_QNN_SDK"

    # Binaries
    install -m 0755 "$UNZIP_OUTPUT_DIR/bin/$PLARFORM_DIR/"qnn* "$QCOM_QNN_SDK/usr/bin/"
    install -m 0755 "$UNZIP_OUTPUT_DIR/bin/$PLARFORM_DIR/qtld-net-run" "$QCOM_QNN_SDK/usr/bin/"

    # Libraries
    cp -a "$UNZIP_OUTPUT_DIR/lib/$PLARFORM_DIR/"*Qnn* "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu/"
    install -m 0755 "$UNZIP_OUTPUT_DIR/lib/$PLARFORM_DIR/libPlatformValidatorShared.so" "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu/"
    install -m 0755 "$UNZIP_OUTPUT_DIR/lib/$PLARFORM_DIR/libcalculator.so" "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu/"

    # Hexagon DSP libraries
    install -m 0755 "$UNZIP_OUTPUT_DIR/lib/hexagon-v${version}/unsigned/libQnnHtpV${version}Skel.so" "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu/"

    # License
    install -m 0644 "$UNZIP_OUTPUT_DIR/LICENSE.pdf" "$QCOM_QNN_SDK/usr/share/doc/$QCOM_QNN_SDK/"

    pushd "$QCOM_QNN_SDK/usr/lib/aarch64-linux-gnu/"
    for f in *Qnn*V[0-9]*; do
        if [[ -f "$f" && "$f" != *V$version* ]]; then
            rm -f "$f"
        fi
    done
    popd
}

COPY_GENIE_SDK 68
COPY_QNN_SDK 68

COPY_GENIE_SDK 73
COPY_QNN_SDK 73
