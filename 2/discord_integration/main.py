#!/usr/bin/env python
import json
from pprint import pprint
import httpx


import discord

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

@client.event
async def on_ready():
    print(f'We have logged in as {client.user}')

@client.event
async def on_message(message):
    if message.author == client.user:
        return

    r = httpx.post('http://localhost:5005/webhooks/rest/webhook', data=json.dumps({
        "sender": str(message.author),
        "message": str(message.content),
        })
)
    responses = json.loads(r.text)
    pprint(responses)

    for response in responses:
        if 'text' in response:
            await message.channel.send(response['text'])



client.run("DISCORD_API_KEY")

