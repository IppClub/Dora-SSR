function main()
    import("collect", {rootdir = os.scriptdir()}).collect_vendor(os.curdir())
end
