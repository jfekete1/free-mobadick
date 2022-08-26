# Free-Mobadick

## How it works?

This little perl script generates a professional license file for MobaXterm.
Using an encryption algorithm and compression.

## Requirements

sudo cpan -f Archive::Zip

## How to use?

```
Usage:
    free-mobadick.pl <UserName> <Version>

    <UserName>:      The Name licensed to
    <Version>:       The Version of MobaXterm you are using
                     Example:    20.5
```

EXAMPLE:

```
PS C:\Users\jfekete1\Github\free-mobadick> .\free-mobadick.pl jfekete1 20.5
[*] Success!
[*] File generated: C:\Users\jfekete1\Github\free-mobadick\Custom.mxtpro
[*] Please move or copy the newly-generated file to MobaXterm's installation path.
[*] If you are using portable version, then just put the file next to the MobaXterm executable.
```

Then copy `Custom.mxtpro` to `C:\Program Files (x86)\Mobatek\MobaXterm`.
