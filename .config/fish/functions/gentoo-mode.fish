function gentoo-mode
    # app-portage/portage-utils
    alias lastsync 'qlop -s | tail -n1'
    alias qtime 'qlop -tv'

    # app-portage/flaggie
    function acckw
        switch $argv[1]
            case a
                sudo flaggie $argv[2] '+kw::~amd64'
            case d
                sudo flaggie $argv[2] '-kw::~amd64'
            case r
                sudo flaggie $argv[2] '%kw::~amd64'
            case v
                sudo flaggie $argv[2] '?kw::~amd64'
            case ''
                return 1
            case '*'
                return 1
        end
    end
end
