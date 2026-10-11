# Configure VS Code

$extensions = @(
    "ms-python.python"
    "dbaeumer.vscode-eslint"
    "eamodio.gitlens"
)

foreach ($ext in $extensions) {
    code --install-extension $ext
}

