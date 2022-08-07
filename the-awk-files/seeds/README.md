## Seeds AWK

This will generate the seed structs as seen in the ./datasets/seeds folder.

Apply the awk in this folder to the nfts.input file in the parent folder (../nfts.input).
`awk -f seeds.awk ../nfts.input`

There are a couple variables you could play around with.

- `max`: changes the amount of seeds per file. Default `1400`.
- `w`: changes the seed size, default: `3`.
- `relative`: setting this to `1` would give a relative position for each word, example: "AAA": [0, 230, 1000, 15005].
  It's the indices you'd get if you'd "append" all sequences together into one gigantic string.
  `0` would give the NFTID plus the index (inside this protein's sequence). Default: `0` (what we use in this repo).
- `base`: change the amount of amino acids (so the protein alphabet) that are available. Default: `20` (what we use in this repo).

This example will generate 1000 seeds with a seed size of 4 per .txt file.
`awk -v w=4 -v max=1000 -f proteins.awk ../nft.input`

The result can be found in the output-folder.
