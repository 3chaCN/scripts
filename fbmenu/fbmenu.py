#!/usr/bin/python
import os 
import re

# create dictionnary {[category][category..][sub]=app}

# list .desktop files

# for each file
## split category ';', append [0], append[i]
### append category[..i]=app : appn as a tuple (app,command,icon)

menu_path="/usr/share/menu"

# generate menu
menu = "\t[submenu] (Applications)\n {}\n\t[end]"
# append \t as many sublevels presents

app_list=os.listdir(menu_path)
raw_menu = {} 
apps = []

class MenuFile():
    def __init__(self):
        self.raw = {}

    def create_entry(self, pkg, needs, section, title, command, desc=None, icon=None):
        self.raw["pkg"] = pkg
        self.raw["needs"] = needs
        self.raw["section"] = section
        self.raw["title"] = title
        if desc is not None: 
            self.raw["longtitle"] = desc
        else:
            self.raw["longtitle"] = None
        self.raw["command"] = command
        if icon is not None: 
            self.raw["icon"] = icon
        else:
            self.raw["icon"] = None 

    def read_file(self, path):
        with open(path, 'r') as f:
            print("Processing {}.".format(path))
            data = f.read()
        m = re.search("section=\"(.*)\"", data)
        self.raw["section"] = m.group().split('=')[1]
        m = re.search("title=\"(.*)\"", data)
        self.raw["title"] = m.group().split('=')[1] 
        m = re.search("command=\"(.*)\"", data)
        self.raw["command"] = m.group().split('=')[1]
        m = re.search("icon=\"(.*)\"", data)
        if m is not None: self.raw["icon"] = m.group().split('=')[1]
    
    def get_pkg(self):
        return self.raw["pkg"]
    def get_name(self):
        return self.raw["title"]
    def get_needs(self):
        return self.raw["needs"]
    def get_desc(self):
        return self.raw["longtitle"]
    def get_category(self):
        return self.raw["section"]
    def get_command(self):
        return self.raw["command"]
    def get_icon(self):
        return self.raw["icon"]
    def terminal_cmd(self, term):
        cmd = "{} -e {}".format(term, self.get_command())
        return cmd
    def generate_menufile(self, path):
        self.menu_file = "?package({}):needs\"{}\" section=\"{}\" \\".format(self.get_pkg(), self.get_needs(), self.get_category())
        self.menu_file += "\n\t\ttitle=\"{}\" \\".format(self.get_name())
        if self.get_desc() is not None: self.menu_file =+ "\n\t\tlongtitle=\"{}\" \\".format(self.get_desc())
        self.menu_file += "\n\t\tcommand=\"{}\" \\".format(self.get_command())
        if self.get_icon() is not None: self.menu_file =+ "\n\t\ticon=\"{}\"".format(self.get_icon())
        with open(path, 'wb+') as f:
            f.write(self.menu_file.encode('utf8'))

class DesktopFile():
    def __init__(self, path):
        self.raw = {}
        self.filename = path.split('/')[-1].replace('.desktop', '')
        with open(path, 'r') as f:
            print("Processing {}.".format(path))
            data = f.read().split('\n')[1:-2]
            # todo : change for remove garbage lines (starting with #, [..], ...)
            for entry in data:
                if entry != "":
                    if "#" not in entry:
                        if "[" not in entry:
                            self.raw[entry.split('=')[0]] = entry.split('=')[1]
    def get_filename(self):
        return self.filename

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
    
    def convert_to_menufile(self, path):
        m = MenuFile()
        try:
            m.create_entry(self.get_name().lower(), "x11", self.get_category().replace(';', '/'), self.get_name, self.get_command())
            m.generate_menufile("/tmp/menu/{}".format(self.get_filename()))
        except:
            print("Not a valid file.")

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
    def __init__(self, name, entries=None, level=2):
        self.name = name
        self.ent = entries
        self.menu = []
        self.level = level
        self.title = "\t"*level + "[submenu] ({}) {{}}\n"

    def get_entries(self):
        return self.ent

    def format_submenu(self):
        self.menu.append(self.title.format(self.name))
        for e in self.ent:
            self.menu.append(e)
        return "".join(self.menu)

class Menu():
    def __init__(self, name, entries=None):
        self.title = "t"

for file in app_list:
    try:
        ap = MenuFile()
        ap.read_file(menu_path + '/' + file)
        entry = MenuEntry(ap.get_name(), ap.get_command(), ap.get_category())
        apps.append(entry)
    except:
        print("Not a valid file.")


for entry in apps:
    raw_menu[entry.get_category()] = entry
    
# formatting final menu
for k in raw_menu.keys():
    SubMenu(k, raw_menu[k].format_entry()).format_submenu()
    
