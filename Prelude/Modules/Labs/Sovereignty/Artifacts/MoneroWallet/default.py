"""MoneroWallet — Crypto wallet artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel
class Network(str, Enum):
    mainnet = "mainnet"; stagenet = "stagenet"; testnet = "testnet"
class Wallet(BaseModel):
    coin: str = "xmr"
    network: Network = Network.mainnet
    cold_storage: bool = True
