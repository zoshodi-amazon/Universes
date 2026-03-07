"""PythonShader — GPU program artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel
class ShaderLang(str, Enum):
    glsl = "glsl"; gdshader = "gdshader"; hlsl = "hlsl"
class ShaderStage(str, Enum):
    vertex = "vertex"; fragment = "fragment"; compute = "compute"
class Shader(BaseModel):
    language: ShaderLang = ShaderLang.glsl
    stage: ShaderStage = ShaderStage.fragment
    inputs: int = 4
