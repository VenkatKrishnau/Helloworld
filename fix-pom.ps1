# Fix pom.xml - Replace <n> tag with <name>
$filePath = "pom.xml"
$content = [System.IO.File]::ReadAllText($filePath)
$content = $content.Replace('<n>HelloWorld</n>', '<name>HelloWorld</name>')
[System.IO.File]::WriteAllText($filePath, $content)

Write-Host "pom.xml fixed successfully!"
