# Write a function that checks if a string is a palindrome

function Get-Palindrome {
    param (
        $Word
    )
    
    $w = $Word.ToCharArray()
    [array]::Reverse($w)
    $x = -join($w)

    "$Word reversed is $x"

    $Word -eq $x
}

Get-Palindrome -Word "Lindsay"

Get-Palindrome -Word "Level"