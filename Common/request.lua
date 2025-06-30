-- Modern request implemenation supporting callbacks

REQUEST_TIMEOUT = 60

function HTTPResponse(request, success)
	-- Wrapper for a response to an HTTP request
	
	return {
		request = request,
		success = success,
		status = knHttpErrorCode(request),
		statusLine = knHttpError(request),
		dataSize = knHttpDataSize(request),
		getHeader = function (self, name)
			return knHttpGetHeader(self.request, name)
		end,
		getData = function (self)
			return knHttpData(self.request)
		end,
		extractArchive = function (self, where)
			return knHttpExtractNxArchive(self.request, where)
		end,
	}
end

function HTTPRequest(method, url, body, headers, onSuccess, onFailure)
	onSuccess = onSuccess or (function () end)
	onFailure = onFailure or onSuccess
	headers = headers or {}
	headers["User-Agent"] = "ShatterClient/" .. knGetAppVersion() .. " SmashHit/1.4.3 KnShim/" .. tostring(knGetShimVersion())
	
	return {
		request = knHttpRequest(method, url, body, headers),
		started = os.time(),
		onSuccess = onSuccess,
		onFailure = onFailure,
		update = function (self)
			local status = knHttpUpdate(self.request)
			
			if status ~= KN_HTTP_PENDING then
				if status == KN_HTTP_DONE and knHttpErrorCode(self.request) == 200 then
					pcallWithLog(function () self.onSuccess(HTTPResponse(self.request, true)) end)
				else
					pcallWithLog(function () self.onFailure(HTTPResponse(self.request, false)) end)
				end
				
				return true
			elseif os.time() - self.started > REQUEST_TIMEOUT then
				pcallWithLog(function () self.onFailure(HTTPResponse(self.request, false)) end)
				return true
			end
			
			return false
		end
	}
end

function HTTPRequestDispatcher()
	return {
		list = {},
		add = function (self, request)
			self.list[#self.list + 1] = request
		end,
		update = function (self)
			for i, v in ipairs(self.list) do
				if v:update() then
					self.list[i] = nil
				end
			end
			
			for i=#self.list, 0, -1 do
				if self.list[i] == nil then
					table.remove(self.list, i)
				end
			end
		end
	}
end

httpRequestDispatcher = HTTPRequestDispatcher()

function httpRequest(method, url, body, headers, onSuccess, onFailure)
	httpRequestDispatcher:add(HTTPRequest(method, url, body, headers, onSuccess, onFailure))
end

function httpGet(url, onSuccess, onFailure)
	httpRequest("GET", url, nil, nil, onSuccess, onFailure)
end

function httpPost(url, body, onSuccess, onFailure)
	httpRequest("POST", url, body, nil, onSuccess, onFailure)
end
