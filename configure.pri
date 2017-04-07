defineTest(hasTool) {
    tool = $$qtConfFindInPath($$1)
    !isEmpty(tool) {
        qtRunLoggedCommand("$$tool $$2", output)|return(false)
        contains(output, $$3): return(true)
    }
    return(false)
}

defineTest(qtConfTest_xcodebuild) {
    hasTool("xcodebuild", "-version", "^Xcode .*"):return(true)
    return(false)
}

defineTest(qtConfTest_git) {
    hasTool("git", "--version", "^git version .*"):return(true)
}