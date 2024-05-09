#!/usr/bin/python
import os 
import re

# create dictionnary {[category][category..][sub]=app}

# list .desktop files

# for each file
## split category ';', append [0], append[i]
### append category[..i]=app : appn as a tuple (app,command,icon)

desktop_path="/usr/share/applications"

# generate menu
menu = "\t[submenu] (Applications)\n {}\n\t[end]"
# append \t as many sublevels presents

app_list=os.listdir(desktop_path)
raw_menu = {} 
apps = []

class DesktopFile():
    def __init__(self, path):
        self.raw = {}
        with open(path, 'r') as f:
            print("Processing {}.".format(path))
            data = f.read().split('\n')[1:-2]
            # todo : change for remove garbage lines (starting with #, [..], ...)
            for entry in data:
                if entry != "":
                    if "#" not in entry:
                        if "[" not in entry:
                            self.raw[entry.split('=')[0]] = entry.split('=')[1]
    def get_name(self):
        if "Name" in self.raw.keys():
            return self.raw["Name"]
        else:
            return self.raw["GenericName"]
    def get_category(self):
        if "Categories" in self.raw.keys():
            return self.raw["Categories"].split(';')[0]
    def get_command(self):
        if "Exec" in self.raw.keys():
            return self.raw["Exec"]
        else:
            return self.raw["TryExec"]
    def get_icon(self):
        if "Icon" in self.raw.keys():
            return self.raw["Icon"]
    def is_console(self):
        try:
            if self.raw["Terminal"] == "true":
                return True
            else:
                return False
        except:
            return False
    
    def terminal_cmd(self, term):
        cmd = "{} -e {}".format(term, self.get_command())
        return cmd

class MenuEntry():
    def __init__(self, name, cmd, cat=None, icon=None):
        self.entry = "\t\t[exec] ({}) {{{}}} <{}>\n" 
        self.name = name
        self.cmd = cmd
        if icon is not None: self.icon = icon
        if cat is not None: 
            self.cat = cat
        else:
            self.cat = "Misc"
    
    def get_category(self):
        return self.cat

    def format_entry(self):
        return self.entry.format(self.name, self.cmd, None)

class SubMenu():
    def __init__(self, name, entries=None):
        self.title = "\t[submenu] ({}) {{}}\n"
        self.name = name
        self.ent = entries
        self.menu = []

    def get_entries(self):
        return self.ent

    def format_submenu(self):
        self.menu.append(self.title.format(self.name))
        for e in self.ent:
            self.menu.append(e)
        return "".join(self.menu)

for file in app_list:
    ap = DesktopFile(desktop_path + '/' + file)
    try:
        entry = MenuEntry(ap.get_name(), ap.get_command(), ap.get_category())
    except:
        print("Not a valid launcher.")
    apps.append(entry)

for entry in apps:
    raw_menu[entry.get_category()] = entry
    
# formatting final menu
for k in raw_menu.keys():
    print(str(SubMenu(k, raw_menu[k].format_entry()).format_submenu()))
    
