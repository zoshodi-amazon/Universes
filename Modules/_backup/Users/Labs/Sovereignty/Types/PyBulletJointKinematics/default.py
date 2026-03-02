"""PyBulletJointKinematics — Joint chain definition artifact (5 params)"""
from enum import Enum
from pydantic import BaseModel, Field
class JointType(str, Enum):
    revolute = "revolute"; prismatic = "prismatic"; fixed = "fixed"; spherical = "spherical"
class JointKinematics(BaseModel):
    dof: int = Field(default=6, ge=1, le=50)
    joint_type: JointType = JointType.revolute
    max_torque_nm: float = Field(default=10.0, gt=0.0, le=1000.0)
    max_velocity_rad_s: float = Field(default=3.14, gt=0.0, le=100.0)
    link_length_m: float = Field(default=0.3, gt=0.0, le=5.0)
