"""ScapyHandshake — Auth capture artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class HandshakeProtocol(str, Enum):
    wpa2 = "wpa2"; eapol = "eapol"; ntlm = "ntlm"
class Handshake(BaseModel):
    protocol: HandshakeProtocol = HandshakeProtocol.wpa2
    interface: str = Field(default="wlan0", description="Capture interface")
    timeout_s: int = Field(default=60, ge=1, le=3600)
