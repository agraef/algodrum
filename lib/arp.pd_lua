local arp = pd.Class:new():register("arp")

function arp:initialize(sel, atoms)
   self.inlets = 1
   self.outlets = 2
   self.notes = {}
   self.idx = 0
   return true
end

function arp:in_1_bang()
   local m = #self.notes
   if m > 0 then
      local i = self.idx % m
      self.idx = (self.idx+1) % m
      self:outlet(1, "float", {self.notes[i+1]})
   end
end

function arp:in_1_list(x)
   local n, v = table.unpack(x)
   if type(n) == "number" and type(v) == "number" then
      local m = #self.notes
      if v > 0 then
	 for i = 1, n do
	    if self.notes[i] == n then
	       -- avoid duplicates
	       return
	    end
	 end
	 self.notes[m+1] = n
	 self.idx = 0
	 self:outlet(2, "float", {#self.notes})
      elseif v == 0 then
	 for i = 1, n do
	    if self.notes[i] == n then
	       table.remove(self.notes, i)
	       self.idx = 0
	       self:outlet(2, "float", {#self.notes})
	       return
	    end
	 end
      end
   end
end
