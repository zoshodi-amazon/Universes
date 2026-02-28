"""PythonDocument — Formatted text artifact (3 params)"""
from enum import Enum
from pydantic import BaseModel
class DocFormat(str, Enum):
    pdf = "pdf"; md = "md"; html = "html"
class DocTemplate(str, Enum):
    report = "report"; manual = "manual"; letter = "letter"
class Document(BaseModel):
    template: DocTemplate = DocTemplate.report
    format: DocFormat = DocFormat.pdf
    title: str = "Untitled"
