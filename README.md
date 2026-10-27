# DATUMARK

DATUMARK is a wallet-owned public file manifest for BOT Chain. File bytes are pinned to IPFS, while URI, filename, MIME type, size and timestamp are recorded in a Solidity contract.

## Original direction

- Physical archive-folder layout with a wine backdrop, cream paper, powder-blue cabinet spine and asymmetric file rows.
- One cabinet per wallet, renameable by its owner.
- Add and remove public file records.
- Secure server-side Pinata upload route: the JWT never enters the browser bundle.
- Existing IPFS URI mode when no upload service is configured.
- Automatic wallet account and network change handling.

## Environment variables

- `VITE_DATUMARK_ADDRESS`: deployed contract address. Public Config value.
- `PINATA_JWT`: Pinata JWT used only by `/api/upload`. Secret value. Never prefix it with `VITE_`.

## Network

BOT Chain, Chain ID 677, RPC `https://rpc.botchain.ai`.