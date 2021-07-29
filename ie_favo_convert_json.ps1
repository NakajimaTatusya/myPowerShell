#requires -version 5
<#
.SYNOPSIS
  Script to convert Internet Explorer's Favorites folder to 
  a JSON formatted text file, that can be used in the Group Policy Setting
  "Managed Bookmarks" (Google Chrome) or
  "Configure Favorites" (Microsoft Edge)
.DESCRIPTION
  The Managed Bookmarks and Configure Favorites Group Policy settings for Chrome and Edge
  can define a set of bookmarks/favorites, that are always forced to the browser's Bookmarks/Favorites.
  If you have already predefined favorites in Internet Explorer, this script will help you convert that
  to the string, you need to enter in the Group Policy Setting.

  The script reads the .URL files in the specified folder and converts the name and URL for each
  to one JSON formatted string.

  It can also read subfolders (one sublevel only)

  *** Note! Don't add too many favorites, because of registry limits!
  *** The Group Policy Editor UI will not allow to paste a too long string
  *** For me the limit was somewhere between 37254 and 41099 characters, although the ADMX specifies maxLength to 1000000

.INPUTS
  None. (Define variables below instead)

.OUTPUTS
  Outputs to JSON formatted text file. Path defined in variable below.

.NOTES
  Version:        1.0
  Author:         Martin Jeppesen, https://www.avantia.dk
  Creation Date:  2020-05-13
  Purpose/Change: Initial script development

  https://www.avantia.dk/blog/2020/5/13/script-to-convert-internet-explorer-favorites-to-managed-bookmarks-in-chrome-edge
  https://docs.microsoft.com/en-us/deployedge/microsoft-edge-policies#windows-registry-settings-247  

#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
$UserProfile = $env:USERPROFILE

# Enter the name of the Managed Bookmarks/Favorites, as they should be named in the browser
$bookmarksTopLevelName = "IE Favorites"

# Enter the path with the favorites stored as .URL files to be converted to Edge/Chrome JSON file
$IEFavoritesPath = "$UserProfile\Favorites"

# Enter the path to the text file, where you want the script to store the JSON formatted string
$JSONFile = "$UserProfile\Documents\ManagedBookmarks.txt"


#-----------------------------------------------------------[Functions]------------------------------------------------------------

# Function to get content from the URL files is based on
# the function made by Oliver Lipkau <oliver@lipkau.net>
# https://gallery.technet.microsoft.com/scriptcenter/ea40c1ef-c856-434b-b8fb-ebd7a76e8d91
# It gets the content of an INI file and returns it as a hashtable
function Get-IniContent ($filePath)
{
    $ini = @{}
    switch -regex -file $FilePath
    {
        "^\[(.+)\]" # Section
        {
            $section = $matches[1]
            $ini[$section] = @{}
            $CommentCount = 0
        }
        "^(;.*)$" # Comment
        {
            $value = $matches[1]
            $CommentCount = $CommentCount + 1
            $name = "Comment" + $CommentCount
            $ini[$section][$name] = $value
        }
        "(.+?)\s*=(.*)" # Key
        {
            $name,$value = $matches[1..2]
            $ini[$section][$name] = $value
        }
    }
    return $ini
}

# Function to get the name and URL for each favorite/bookmark
function Get-BookmarksList ($files)
{
$list = foreach ($item in $files)
    {
        try
            {
            # Get the name based on the .URL filename
            $BookmarkName = $item.Name.TrimEnd(".url")

            # Read the URL from the file content using the Get-IniContent function
            $iniContent = Get-IniContent $item.FullName
            $BookmarkURL = $iniContent["InternetShortcut"]["URL"]
            }

        catch
            {
            $BookmarkName = $item.FullName
            $BookmarkURL = $null
            }

        [PSCustomObject]@{
            url = $BookmarkURL
            name = $BookmarkName
            }
    }
    return $list
}


#-----------------------------------------------------------[Execution]------------------------------------------------------------

#Create the json file using info on the name of the Managed Bookmarks
$jsonTLNamePrefix = '[{"toplevel_name": "' 
$jsonTLNameSuffix = '"},'

$jsonTLNameFull = $jsonTLNamePrefix + $bookmarksTopLevelName + $jsonTLNameSuffix

New-Item $JSONFile -ItemType File -Value $jsonTLNameFull


#Enumerate IE Favorites folders in one level only
$folders = Get-ChildItem $IEFavoritesPath -Recurse -Depth 1 | ?{ $_.PSIsContainer }


#Create Folders in Bookmarks and create bookmarks in these folders
foreach ($folder in $folders)
    {
    # Get the name for the folder as it will be displayed in the browser based on file folder name
    $folderName = $folder.Name

    # Get each .URL file from the subfolder
    $folderPath = $folder.FullName + "\*.url"
    $folderURLFiles = Get-ChildItem $folderpath

    # Get the URLs and names of the favorites using the Get-BookmarksList function
    $folderBookmarksList = Get-BookmarksList ($folderURLFiles)


    # Create the JSON formatting for the subfolder
    $folderJSONStart1 = '{"name": "' 
    $folderJSONStart2 = '", "children":'

    $folderJSONStart = $folderJSONStart1 + $folderName + $folderJSONStart2


    $folderBookmarksJSON = $folderBookmarksList | ConvertTo-Json -Compress

    $folderJSONEnd = "},"

    $folderJSONcomplete = $folderJSONStart + $folderBookmarksJSON + $folderJSONEnd

    # Add the JSON formatted subfolder to the text file
    Add-Content $JSONFile $folderJSONcomplete -NoNewline
    }




# Get the favorites in the root of the Favorites folder
$URLFiles = Get-ChildItem $IEFavoritesPath "*.url"

# Get the URLs and names of the favorites using the Get-BookmarksList function
$rootBookmarksList = Get-BookmarksList ($URLFiles)


#Convert bookmarks to json
$rootBookmarksJSON = $rootBookmarksList | ConvertTo-Json -Compress

# Remove the first [, because it already exist in the file
$rootJSONTrimmed = $rootBookmarksJSON.Trimstart("[")

# Add the favorites/bookmarks from the Favorites root folder to the JSON formatted text file
Add-Content $JSONFile $rootJSONTrimmed -NoNewline
