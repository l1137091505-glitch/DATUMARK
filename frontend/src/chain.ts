import { ethers } from "ethers";
export const CHAIN_ID=677;
export const CHAIN_HEX="0x2A5";
export const RPC_URL="https://rpc.botchain.ai";
export const EXPLORER="https://scan.botchain.ai";
export const CONTRACT_ADDRESS=(import.meta.env.VITE_DATUMARK_ADDRESS||"").trim();
export const ABI=[
  "function cabinetCount() view returns (uint256)",
  "function recordCount() view returns (uint256)",
  "function createCabinet(string label)",
  "function renameCabinet(string newLabel)",
  "function addRecord(string uri,string name,string mimeType,uint64 size) returns (uint256 recordId)",
  "function removeRecord(uint256 recordId)",
  "function getCabinet(address owner) view returns ((string label,address owner,uint64 createdAt,uint64 updatedAt,uint256 liveRecords,bool exists))",
  "function listRecords(address owner,uint256 offset,uint256 limit) view returns ((string uri,string name,string mimeType,uint64 size,uint64 addedAt,bool exists)[] entries,uint256[] ids,uint256 total)"
];
export type EthereumProvider={request:(args:{method:string;params?:unknown[]})=>Promise<unknown>;on?:(event:string,handler:(...args:unknown[])=>void)=>void;removeListener?:(event:string,handler:(...args:unknown[])=>void)=>void};
declare global{interface Window{ethereum?:EthereumProvider}}
export async function ensureChain(){
  if(!window.ethereum)throw new Error("Install a browser wallet first.");
  const current=await window.ethereum.request({method:"eth_chainId"}) as string;
  if(current.toLowerCase()===CHAIN_HEX.toLowerCase())return;
  try{await window.ethereum.request({method:"wallet_switchEthereumChain",params:[{chainId:CHAIN_HEX}]});}
  catch(error){if((error as {code?:number}).code!==4902)throw error;await window.ethereum.request({method:"wallet_addEthereumChain",params:[{chainId:CHAIN_HEX,chainName:"BOT Chain",nativeCurrency:{name:"BOT",symbol:"BOT",decimals:18},rpcUrls:[RPC_URL],blockExplorerUrls:[EXPLORER]}]});}
}
export function reader(){if(!CONTRACT_ADDRESS)return null;const provider=new ethers.JsonRpcProvider(RPC_URL,{chainId:CHAIN_ID,name:"BOT Chain"});return new ethers.Contract(CONTRACT_ADDRESS,ABI,provider);}
export async function writer(){if(!CONTRACT_ADDRESS)throw new Error("Contract address is not configured.");if(!window.ethereum)throw new Error("Install a browser wallet first.");await ensureChain();const provider=new ethers.BrowserProvider(window.ethereum as ethers.Eip1193Provider);return new ethers.Contract(CONTRACT_ADDRESS,ABI,await provider.getSigner());}