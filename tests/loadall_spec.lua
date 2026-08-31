package.path = "./?.lua;" .. package.path

-- Every file the game will load has to compile, and every file in the folder has
-- to be listed in the .toc. A file that compiles but is not listed is dead code
-- that looks live; a file listed but missing takes the whole addon down at login.
describe("the shipped addon", function()
  local SHIPPED = { "Realms.lua", "Link.lua", "Core.lua" }

  it("compiles every file it ships", function()
    for _, file in ipairs(SHIPPED) do
      local chunk, err = loadfile(file)
      assert.is_truthy(chunk, string.format("%s does not compile: %s", file, tostring(err)))
    end
  end)

  it("lists every shipped file in the toc, and nothing it does not ship", function()
    local toc = assert(io.open("MythicPlusLogLink.toc", "r"))
    local text = toc:read("*a")
    toc:close()

    local listed = {}
    for line in string.gmatch(text, "[^\r\n]+") do
      local file = string.match(line, "^%s*([%w_]+%.lua)%s*$")
      if file then listed[#listed + 1] = file end
    end
    assert.same(SHIPPED, listed)
  end)

  it("declares a title, a version and an interface", function()
    local toc = assert(io.open("MythicPlusLogLink.toc", "r"))
    local text = toc:read("*a")
    toc:close()
    assert.is_truthy(string.match(text, "## Interface: %d"))
    assert.is_truthy(string.match(text, "## Title: %S"))
    assert.is_truthy(string.match(text, "## Version: %d"))
  end)
end)
