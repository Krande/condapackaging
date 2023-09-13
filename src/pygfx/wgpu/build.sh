cp "${RECIPE_DIR}/download-wgpu-native.py" .
cp "${RECIPE_DIR}/codegen_report.md" "wgpu/resources/codegen_report.md"
python download-wgpu-native.py
python -m pip install . -vv