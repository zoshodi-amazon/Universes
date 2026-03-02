"""GhidraBinaryAnalysis — Disassembly/decompilation artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class TargetArch(str, Enum):
    arm = "arm"; arm64 = "arm64"; x86 = "x86"; x86_64 = "x86_64"; mips = "mips"; riscv = "riscv"
class AnalysisDepth(str, Enum):
    quick = "quick"; standard = "standard"; deep = "deep"
class BinaryAnalysis(BaseModel):
    arch: TargetArch = TargetArch.arm
    depth: AnalysisDepth = AnalysisDepth.standard
    entry_point: int = Field(default=0, ge=0)
    decompile: bool = True
    export_format: str = Field(default="json", description="json|c|asm")
