"""ScapyPacket — Crafted network packet artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class Protocol(str, Enum):
    tcp = "tcp"; udp = "udp"; icmp = "icmp"; arp = "arp"
class Packet(BaseModel):
    protocol: Protocol = Protocol.tcp
    src_port: int = Field(default=12345, ge=1, le=65535)
    dst_port: int = Field(default=80, ge=1, le=65535)
    payload_bytes: int = Field(default=0, ge=0, le=65535)
