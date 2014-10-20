Pockit
======

A Technic Platform modpack and modpack packaging system.

About the Modpack
-----------------

Pockit is developed and maintained by a couple of Minecraft enthusiasts.
The first is interested in magic, mystery, and legend, while the second is interested in mining, building, and automating.
Together they love to explore, mess around with new toys, and get a challenge from Minecraft.

The primary goal of this modpack is to achieve those desires.
This modpack provides lots of exploration opportunities to improve the longevity of the world you are playing in.
The Nether and End realms have been expanded upon to provide new experiences, giving you a reason to stick around longer.
Along with the default dimensions, new ones have been added - ripe for exploring.
These new dimensions are not common dimensions seen in other modpacks, check out the dimension list below.
And of course, the overworld has been *over*hauled as well.
There are lots of biomes to explore and build in.
The once dull ocean is now thriving with life and color.
Cave exploration isn't as dull and "gray" now that there are themed caverns.

As you're exploring the world, you will encounter magical items.
With those items you will gain abilities to help you become stronger and fight more challenging enemies.
Or you could use the abilities to be lazy around the house.
You'll find magical plants and incantations to make things easier.
However, be wary when you go out at night.
Some mobs have special abilities and are itching to pick a fight.
Loot in perilous dungeons awaits you, if you can defeat the fierce boss guarding it.
Dungeons spoken of in tales of old lie in wait, yearning to be discovered.

Maybe you're more of a cave dweler, a resource hoarder, a miner, or a tinkerer.
There are more ores and resources to be found.
Build machines to process your resources.
Attach them together with pipes and wires to automate your entire base.
Too lazy to go mining? Send a machine to do it for you!
Like to craft? There are tons of new recipes available.
A world of possibilies has been opened with the new food available.
Yum.

**tl;dr:** A modpack for those interested in magic and/or technology that caters to explorers.
Provides more challenges than vanilla Minecraft and is suited for longer-lived worlds and doesn't have rapid progression.

### Dimensions

**TODO**

### Featured Mods

**TODO**

### Known Issues

* "It Fell From the Sky" seems to cause the server to crash due to an incompatibility with Ars Magica 2.
    A NullPointerException is sometimes thrown after Pigzilla has been walking around for a while.
    Please use Pigzilla with caution!

About the Modpack Packaging System
-----------------------------------

The packaging system is written in Ruby.
Although... *no knowledge of how to write Ruby is required to build a modpack.*
All core functionality and libraries do not contain any modpack specifics.
Information about the modpack and the mods it contains is in JSON files.
This structure makes it very easy to modify the contents of the modpack.
It produces two packages - a client zip and a server zip.

This tool **does not:**
* Publish your modpack to the web
* Update your Technic Platform modpack
* Bake you cookies

### Building

rake is the tool used to build the modpack.
The default task builds the client and server packages.
```sh
rake
```

To build just the client or just the server, you can use the following:
```sh
rake client
rake server
```
This will produce `pockit-<version>-<mc version>-client.zip` and `pockit-<version>-<mc version>-server.zip`.

The clean task will remove the client and server zip packages as well as any downloaded mod files.
```sh
rake clean
```

All intermediate packaging is performed in the pkg/ directory.

The packaging system requires that the mod files are not protected or gated.
This means adf.ly, mediafire, or other similar sites can't be linked to.

**Note:** For the Pockit modpack, mods are downloaded from a password-protected artifact manager.
    You will not be able to build the Pockit modpack (download mod files) without a username and password.
    If you *absolutely* want to build Pockit, and the posted releases don't suit your needs, contact one of this project's contributors.
    The reason the artifact manager is password protected is to not provide an ad-free alternative to mod developer downloads.
    Please support the original mod developers by using their links and/or donating. :)

The packaging system supports Basic HTTP Authentication.
Simply pass the username and password as follows:
```sh
rake http_user=USERNAME http_pass=PASSWORD
```

### Forking

Making your own modpack variation is *very* easy.
All you need to do is fork this project and change the contents of the `.modpack`, `.modlist`, and possibly `.mod` files.
The contents of each file are self-explanitory, since they are labeled.
This directory structure allows a modpack to be developed for multiple Minecraft versions.
It also acts as a mod information database.
Not all mods kept in the collection have to be used in a modpack.
Below is a description of the files and their structure:

#### .modpack

The `.modpack` file contains information about the modpack itself, such as the name, authors, and website.
This file is where you'll set the modpack version and Minecraft version the modpack is made for.
References to the mods used in the client and server are also listed here.
There should be one `.modpack` file, otherwise the packaging system will not know what to build.

#### .modlist

The `.modlist` file is a list of mod IDs (more on this in a bit).
The list specifies *all* mods that will be included in the package.
Generally, there will be two `.modlist` files - one for the client and one for the server.
Adding or removing a mod from the package is as simple as adding or removing its ID from the file.

#### .mod files

Each `.mod` file contains information about the mod, like its version, author, website, and download URL.
An important piece of information is the ID.
The ID can be anything, but should reflect the name or purpose of the mod.
All of the `.mod` files are contained in the mods/ directory under their respective Minecraft version.

**Please note:** All mods that you wish to use must be in the version directory that is the same as the version listed in your `.modpack` file.
    For example: Your modpack is for Minecraft 1.7.10. All mods you use must be in mods/1.7.10/.
    Some mods may be compatible with multiple versions of Minecraft, but they must be in the same version directory.
    
By convention, each file has its ID then the version separated by an underscore.
This convention doesn't have to be followed, but the packaging system has an easier time finding the mod if it is followed.
Multiple versions of the same mod for the same Minecraft version are allowed, however do this with caution.
The packaging system will try to pick the latest version, but may get it wrong.

Links
-----

* Technic Pack (Technic Platform) http://www.technicpack.net/
* Minecraft http://www.minecraft.net/
