from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import dotenv_values
from pymongo import MongoClient


config = dotenv_values(".env")

app = FastAPI()

origins = [
    "http://192.168.56.5",
    "http://192.168.56.5:8080",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def startup_db_client():
    print("Connecting to the MongoDB database!")
    app.mongodb_client = MongoClient(f'mongodb://{config["MONGODB_USERNAME"]}:{config["MONGODB_PASSWORD"]}@{config["HOST"]}', tls=False)
    app.database = app.mongodb_client[config["DB_NAME"]]
    app.collection = app.database["name"]
    try:
        app.mongodb_client.admin.command("ping")
        print("Connected to the MongoDB database!")
    except Exception as e:
        print("Unable to connect to the database")
        print(f"error: {e}")
    
    if app.collection.find({ "_id": 1}).to_list() == []:
        print("Database is empty!\nInserting data!")
        app.collection.insert_one({ "_id": 1, "name": "Ward Smeyers" })


@app.on_event("shutdown")
def shutdown_db_client():
    print("Closing connection to MongoDB!")
    app.mongodb_client.close()
    print("Connection to MongoDB closed!")


@app.get("/")
def read_root():
    return {"Hello": "World"}


@app.get("/user")
def read_item():
    resp = app.collection.find({ "_id": 1}).to_list()
    return {"name": resp[0].get("name")}


@app.post("/user/update")
def read_item(name = "Ward Smeyers"):
    app.collection.update_one({ "_id": 1 }, { "$set": { "name": name } })
    
    resp = app.collection.find({ "_id": 1}).to_list()
    return {"name": resp[0].get("name")}
