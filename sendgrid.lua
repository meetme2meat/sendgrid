
local ltn12 = assert(require("ltn12"))
local cjson = assert(require('cjson'))
local https = assert(require("ssl.https"))
local SendGrid = {}

function SendGrid:new(opts)
  local sendgridObj = {}
  sendgridObj.token = opts.token
  setmetatable(sendgridObj, {__index = self})
  return sendgridObj
end

function SendGrid:send(opts)
  local params = {}
  local personalization = {}
  personalization[1] = {}
  params.personalizations = personalization

  if opts.to == nil then
    print('please provide a to field')
  end

  if type(opts.to) ~= 'table' then
    print('to should be a table')
  end

  personalization[1].to = opts.to

  if opts.cc ~= nil then
    personalization[1].cc = opts.cc
  end

  if opts.bcc ~= nil then
    personalization[1].bcc = opts.bcc
  end

  if opts.subject ~= nil then
    personalization[1].subject = opts.subject
  end

  if opts.headers ~= nil then
    personalization[1].headers = opts.headers
  end

  if opts.subsitutions ~= nil then
    personalization[1].subsitutions = opts.subsitutions
  end

  if opts.custom_args ~= nil then
    personalization[1].custom_args = opts.custom_args
  end

  if opts.send_at ~= nil then
    personalization[1].send_at = opts.send_at
  end

  if opts.from == nil then
    print("from address is nil")
  end

  if type(opts.from) == 'table' then
    if opts.from.email ~= nil then
      params.from = opts.from
    else
      print("email address must be present")
    end
  else
    print('the from should be a table')
  end

  if opts.content ~= nil then
    if type(opts.content) ~= 'table' then
      print('content must be a table')
    else
      params.content = opts.content
      -- if opts.content.type == nil or opts.content.value == nil then
      --   print("the type and the value for the content must be present")
      -- else
      --   params.content = opts.content
      -- end
    end
  end

  local response = {}
  print(self.token)
  local payload = cjson.encode(params)
  print(payload)
  local one, code, headers, status = https.request {
    method = 'POST',
    url = 'https://api.sendgrid.com/v3/mail/send',
    headers = {
      Accept = "*/*",
      Host = 'api.sendgrid.com',
      ['Content-Type'] = 'application/json',
      ["Content-Length"] = tostring(#payload),
      Authorization = 'Bearer ' .. self.token,
    },
    source = ltn12.source.string(payload),
    sink = ltn12.sink.table(response)
  }

  return response
end


function SendGrid:getToken()
  return self.token
end

return SendGrid
