package("dora-go")
    set_base("go")
    on_load(function (package)
        -- Keep xmake-repo's host variants, checksums and installation rules.
        -- Fetch from Go's download CDN directly before the redirecting site:
        -- go.dev downloads have stalled on both Linux and Windows CI runners.
        local urls = {}
        for _, url in ipairs(package:urls()) do
            table.insert(urls, (url:gsub("https://go%.dev/dl/", "https://dl.google.com/go/")))
            table.insert(urls, url)
        end
        package:urls_set(table.unique(urls))
    end)
package_end()
