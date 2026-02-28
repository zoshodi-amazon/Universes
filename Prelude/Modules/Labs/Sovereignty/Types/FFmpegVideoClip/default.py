"""FFmpegVideoClip — Rendered video artifact (4 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class VideoCodec(str, Enum):
    h264 = "h264"; h265 = "h265"; vp9 = "vp9"; av1 = "av1"
class VideoClip(BaseModel):
    width_px: int = Field(default=1920, ge=64, le=7680)
    height_px: int = Field(default=1080, ge=64, le=4320)
    fps: int = Field(default=30, ge=1, le=120)
    codec: VideoCodec = VideoCodec.h264
