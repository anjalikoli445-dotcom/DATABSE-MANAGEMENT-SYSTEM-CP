import os

class Config:
    SECRET_KEY = os.environ.get("SECRET_KEY", "tripwise-secret-change-me")
    DB_HOST = os.environ.get("DB_HOST", "localhost")
    DB_USER = os.environ.get("DB_USER", "root")
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "TripWise@123")
    DB_NAME = os.environ.get("DB_NAME", "tripwise")