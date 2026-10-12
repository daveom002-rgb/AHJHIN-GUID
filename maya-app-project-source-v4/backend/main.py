from fastapi import FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
import models

app = FastAPI(title="Maya AI Agent Backend API", version="1.0.0")

@app.get("/")
def read_root():
    return {"status": "online", "system": "Maya AI Agent"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}
