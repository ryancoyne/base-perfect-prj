// Generated automatically by Perfect Assistant
// Date: 2018-09-26 13:49:49 +0000
import PackageDescription
let package = Package(
	name: "base_prj",
	targets: [],
	dependencies: [
		.Package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Notifications.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
        // We will be using my Perfect local auth, as it has some custom modifications to the StORM and PostgresStORM classes.
//        .Package(url: "https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
        .Package(url: "https://github.com/ryancoyne/Perfect-LocalAuthentication-PostgreSQL-ryan.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-OAuth2.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-CURL.git", versions: Version(3,0,0)..<Version(3,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/michaelsilvers/SwiftGD.git", versions: Version(1,0,0)..<Version(1,9223372036854775807,9223372036854775807)),
		.Package(url: "https://mikesilvers@bitbucket.org/clearcodex/jsonconfigenhanced.git", versions: Version(1,0,0)..<Version(1,9223372036854775807,9223372036854775807)),
		.Package(url: "https://github.com/iamjono/SwiftMoment.git", versions: Version(1,0,0)..<Version(1,9223372036854775807,9223372036854775807)),
	]
)
