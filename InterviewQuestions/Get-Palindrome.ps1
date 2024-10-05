# Write a function that checks if a string is a palindrome or not.
function Get-Palindrome {
    param (
        [string]$Word
    )
    $w = $Word.ToCharArray()
    [array]::Reverse($w)
    $x = -join ($w)

    if ($Word -eq $x) {
        Write-Host "The word $Word is a palindrome! Reversed is $x"
    }
    else {
        Write-Host "The word $Word is not a palindrome. Its reverse is $x"
    }
}

$Word = Read-Host "Enter a word: "
Get-Palindrome -Word $Word