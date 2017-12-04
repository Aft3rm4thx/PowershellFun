function Remove-EmptyFolder ([String]$path) {
	#Recursive Call to "Walk the Tree"
	Get-ChildItem -LiteralPath:$path -Directory | ForEach-Object { Remove-EmptyFolder -path:$($_.FullName) }
	
	#Base Case
	if (@(Get-ChildItem -LiteralPath:$path).Count -eq 0){
    	Write-Output "Deleting Folder $path"
		Remove-Item -LiteralPath:$path -Force
	}
}

# Put full source path here
$DESTINATION = "C:\temp"

# Instantiate empty arrays that we will append with our filters per server
$fe = @()
$de = @()
$fe += Get-ChildItem $DESTINATION -Recurse -Attributes !Directory -Filter "fileException.log" | Select-Object -ExpandProperty FullName
$de += Get-ChildItem $DESTINATION -Recurse -Attributes Directory -Filter "directoryException" | Select-Object -ExpandProperty FullName

#Collect all the files in the destination 
$files = Get-ChildItem $DESTINATION -Recurse -Attributes !Directory | Select-Object -ExpandProperty FullName
#Loop through our files to delete all files minus exceptions
foreach ($file in $files) {
    if ($de -contains (Get-Item $file).Directory.FullName -or $((Get-Item $file) | % {$_.FullName}) -like "*$de*") {
            "$File in exclusion list, moving on."
        }
    else {
        Write-Output "Deleting file: $file"
        Remove-Item $file -Force
    }
}
    
#Call function from above
Remove-EmptyFolder $DESTINATION