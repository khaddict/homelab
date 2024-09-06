from fastapi import FastAPI, HTTPException
from fastapi.responses import RedirectResponse
import subprocess
from enum import Enum

app = FastAPI()

@app.get("/")
async def root():
    return RedirectResponse(url="/docs")
