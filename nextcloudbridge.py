#! /usr/bin/python3

"""
This simple server emulates a owncloud server for gnome-online-accounts
Pass the server name to select the right URLs (only posteo supported now)
"""

from sys import argv,exit
import uvicorn
from starlette.applications import Starlette
from starlette.routing import Route, Mount
from starlette.requests import Request
from starlette.responses import Response, RedirectResponse

async def homepage(request: Request):
    return Response()

async def davPosteo(request: Request):
    mapping = {
        "caldav": "https://posteo.de:8443/calendars/gmonaco",
        "carddav": "https://posteo.de:8443/addressbooks/gmonaco",
    }
    return RedirectResponse(mapping[request.path_params["type"]])

posteo = Starlette(
    debug=False,
    routes=[
        Route("/.well-known/{type}", davPosteo, methods=["PROPFIND"]),
        Mount(
            "/remote.php",
            routes=[
                Route("/webdav/", homepage),
                Route("/{type}/", davPosteo, methods=["PROPFIND"]),
            ],
        ),
    ],
)

if __name__ == '__main__':
    name = argv[0].replace("./", "")
    if len(argv) < 2:
        print(f"Usage: {name} <service>")
        exit(-1)
    port = 8123 if argv[1] == "posteo" else 8456
    uvicorn.run(f"nextcloudbridge:{argv[1]}", port=port)
