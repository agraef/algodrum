local presetman = pd.Class:new():register("presetman")

function presetman:initialize(sel, atoms)
   self.inlets = 1
   self.outlets = 1
   self.id = 0
   if type(atoms[1]) == "number" then
      self.id = math.floor(atoms[1])
   end
   return true
end

local function file_exists(name)
   local f = io.open(name, "r")
   if f~=nil then
      io.close(f)
      return true
   else
      return false
   end
end

function presetman:in_1_bang()
   local fname = string.format("%s../presets/%d.pat", self._loadpath, self.id)
   self:outlet(1, "float", {file_exists(fname) and 1 or 0})
end

function presetman:in_1_load()
   local fname = string.format("%s../presets/%d", self._loadpath, self.id)
   if file_exists(fname .. ".pat") then
      -- load the pattern
      pd.send("pattern", "read", {fname .. ".pat"})
      -- load the params
      pd.send("params", "read", {fname .. ".par"})
      self:outlet(1, "float", {1})
   else
      self:outlet(1, "float", {0})
   end
end

function presetman:in_1_save()
   local fname = string.format("%s../presets/%d", self._loadpath, self.id)
   -- save the pattern
   pd.send("pattern", "write", {fname .. ".pat"})
   -- save the params
   pd.send("params", "write", {fname .. ".par"})
   -- verify
   self:outlet(1, "float", {file_exists(fname .. ".pat") and 1 or 0})
end
