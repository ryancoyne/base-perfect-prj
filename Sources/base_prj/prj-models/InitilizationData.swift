//
//  InitilizationData.swift
//  bucket
//
//  Created by Mike Silvers on 8/8/18.
//

import Foundation
import PostgresStORM
import PerfectLocalAuthentication

struct SampleUser {
    static let user1 = "SAMPLE1S-AMPL-E1SA-MPLE-1SAMPLE1SAMP"
    static let user2 = "SAMPLE2S-AMPL-E2SA-MPLE-2SAMPLE2SAMP"
}

final class InitializeData {
    
    //MARK:-
    //MARK: Create the Singleton
    private init() {
    }
    
    static let sharedInstance = InitializeData()
    
    func addSampleUsers() {
    
        let tbl = Account()
        
        let createdtime = RMServiceClass.getNow()
        
        var checkuser = "SELECT id FROM public.account WHERE id = '\(SampleUser.user1)'; "
        var tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO public.account "
            checkuser.append("(id,username,email,usertype, source, detail) VALUES(" )
            checkuser.append("'\(SampleUser.user1)',")
            checkuser.append("'sample1',")
            checkuser.append("'bucket.sample1@gmail.com',")
            checkuser.append("'standard',")
            checkuser.append("'local',")
            checkuser.append("'{\"created\":\(createdtime)}')")
            print("Adding user: \(checkuser)")
            _ = try? tbl.sqlRows(checkuser, params: [])
            
            let acc = Account()
            _ = try? acc.get(SampleUser.user1)
            acc.makePassword("B0ck0TB!")
            _ = try? acc.save()
        }
        
        checkuser = "SELECT id FROM public.account WHERE id = '\(SampleUser.user2)'; "
        tr = try? tbl.sqlRows(checkuser, params: [])
        if let thecount = tr?.count, thecount == 0 {
            // it does not exist - add it
            checkuser = "INSERT INTO public.account "
            checkuser.append("(id,username,email,usertype, source, detail) VALUES(" )
            checkuser.append("'\(SampleUser.user2)',")
            checkuser.append("'sample2',")
            checkuser.append("'bucket.sample2@gmail.com',")
            checkuser.append("'standard',")
            checkuser.append("'local',")
            checkuser.append("'{\"created\":\(createdtime)}')")
            print("Adding user: \(checkuser)")
            _ = try? tbl.sqlRows(checkuser, params: [])
            
            let acc = Account()
            _ = try? acc.get(SampleUser.user2)
            acc.makePassword("B0ck0TB!")
            _ = try? acc.save()

        }

    }
    
//    func addLedgerAccountTypes() {
//        let tbl = LedgerAccountType()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO \(tbl.table()) "
//        checkuser.append("(created, createdby,account_group,title,description) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Code', 'Code Creation', 'Customer Code Creation'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Code', 'Code Void', 'Customer Code Void'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','CashOut', 'Cashout','Customer Cashout'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Note', 'Note On Account','Note on a customer account') ")
//
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addLedgerTypes() {
//        let tbl = LedgerType()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO \(tbl.table()) "
//        checkuser.append("(created, createdby,title,description) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Liability', 'Liability Type Account'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Asset', 'Asset Type Account') ")
//
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addLedgerAccounts() {
//
//        let tbl = LedgerAccount()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO \(tbl.table()) "
//        checkuser.append("(created, createdby,ledger_account_type_id,title,description) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)',1,'Code Creation', 'Customer Code Creation') ")
//
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addPOS() {
//        let tbl = POS()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO \(tbl.table()) "
//        checkuser.append("(created, createdby, name,model) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Clover', 'C300'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Clover','Clover Station') ")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//
//    }

//    func addContactTypes() {
//
//        let tbl = ContactType()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO \(tbl.table()) "
//        checkuser.append("(created, createdby, name,description) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)' ,'billing','This is the main billing contact for the account.'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','manager','This is a manager for the account.'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','admin','This is the main billing contact for the account.'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','billing','This is an administrative contact for the account.')")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }

    
//    func addCashoutGroup() {
//
//        let usa = Country()
//        try? usa.find(["code_alpha_2":"US"])
//
//        let singapore = Country()
//        try? singapore.find(["code_alpha_2":"SG"])
//
//        let tbl = CashoutGroup()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var schema = usa.code_alpha_2!.lowercased()
//
//        // Prepaid Card Group:
//        var checkuser = "INSERT INTO \(schema).\(tbl.table()) "
//        checkuser.append("(created, createdby, group_name,description, country_id, picture_url, icon_url, display_order, display, option_layout, long_description, detail_disbursement_reasons) ")
//        checkuser.append(" VALUES ")
//        var pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/prepaidcard/backgrounds/transfer_bank_account_background.png")
//        var pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/prepaidcard/icons/prepaid_card_icon.png")
//        checkuser.append(" ('\(created_time)','\(server_user)','Prepaid Card','This card allows users to purchase anything using the giftcard.', \(usa.id!),'\(pic)','\(pic_icon)', 2, true, 'double', 'Cha-ching!  Shop at your favorite retailers with your prepaid card.  Note that these are virtual cards and cannot be used in physical stores.', \(USDetailDisbursementReasons.closedLoopCard)), ")
//
//        // Gift Card Group:
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/giftcard/backgrounds/gift_card_background.png")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/giftcard/icons/gift_card_icon.png")
//        checkuser.append(" ('\(created_time)','\(server_user)','Gift Card','This card allows users to purchase from specific retailers using the giftcard.', \(usa.id!),'\(pic)','\(pic_icon)',1, true, 'double', 'Choose from hundreds of gift cards to your favorite stores and restaurants.  Note that these are virtual gift cards and some merchants may not accept them in stores.  Please check with the merchant.', \(USDetailDisbursementReasons.openLoopCard)), ")
//
//        // Donate Group:
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/donate/backgrounds/donate_to_charity_background.png")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/donate/icons/donate_icon.png")
//        checkuser.append(" ('\(created_time)','\(server_user)','Donate','This allows the user to donate to a specific cause.', \(usa.id!),'\(pic)','\(pic_icon)',3, true, 'single', 'Choose from hundreds of charities and give back to your community.', \(USDetailDisbursementReasons.donation)), ")
//
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/")
//        checkuser.append(" ('\(created_time)','\(server_user)','Bucket Coin','This is the cryptocurrency for Bucket users.', \(usa.id!),null,null,4, true, 'double', null, \(USDetailDisbursementReasons.crypto))")
//
//        print("Adding cashout groups for \(schema): \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//        schema = singapore.code_alpha_2!.lowercased()
//
//        checkuser = "INSERT INTO \(schema).\(tbl.table()) "
//        checkuser.append("(created, createdby, group_name,description, country_id, picture_url,icon_url, display_order, display, option_layout, long_description) ")
//        checkuser.append(" VALUES ")
//
////        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
////        pic.append("/backgrounds/")
////        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
////        pic_icon.append("/icons/")
////        checkuser.append(" ('\(created_time)','\(server_user)','TopUp','', \(singapore.id!),'\(pic)','\(pic_icon)',1, true, 'double', null),")
//
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/banktransfer/backgrounds/transfer_bank_account_background.png")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/banktransfer/icons/transfer_to_bank_icon.png")
//        checkuser.append(" ('\(created_time)','\(server_user)','Transfer To Bank Account','Cash out to a bank account of your choice.', \(singapore.id!),'\(pic)','\(pic_icon)',2, true, 'double', null),")
//
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/bucketcoin/backgrounds/")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/bucketcoin/icons/")
//        // The pic and pic_icon are being set to null for now since we do not have any images just yet.
//        checkuser.append(" ('\(created_time)','\(server_user)','Bucket Coin','This is the cryptocurrency for Bucket users.', \(singapore.id!),null,null,3, true, 'double', null), ")
//
//        pic = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic.append("/groups/donate/backgrounds/donate_to_charity_background.png")
//        pic_icon = EnvironmentVariables.sharedInstance.ImageBaseURL!
//        pic_icon.append("/groups/donate/icons/donate_icon.png")
//        checkuser.append(" ('\(created_time)','\(server_user)','Donate','', \(singapore.id!),'\(pic)','\(pic_icon)',1, true, 'single', 'Choose from hundreds of charities and give back to your community.')")
//
//        print("Adding cashout groups for \(schema): \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//
//    }

//    func addCashoutOption() {
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        let usa = Country()
//        try? usa.find(["code_alpha_2":"US"])
//
//        let singapore = Country()
//        try? singapore.find(["code_alpha_2":"SG"])
//
//        let usa_cg = CashoutGroup()
//
//        var schema = usa.code_alpha_2!.lowercased()
//
//        var ussql = ""
//        let uscg = try? usa_cg.sqlRows("SELECT * FROM \(schema).cashout_group WHERE country_id = \(usa.id!) ORDER BY display_order DESC ", params: [])
//        for i in uscg! {
//            switch i.data.cashoutGroupDic.group_name {
//            case "Prepaid Card"?:
//                // card 1
//                var imageName = "visa_icon.png"
//                var smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/prepaidcard/small/\(imageName)")
//                var largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/prepaidcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Visa',")
//                ussql.append("'visa.com', ")
//                ussql.append("'The VISA prepaid card may be used anywhere online!', ")
//                ussql.append("'Come join the VISA family and use this card worldwide!', ")
//                // Confirmation Description:
//                ussql.append(" 'prepaid card to will be sent to {email}.  Use this prepaid card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null, ")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"FIS\" }'),")
//                // card 2
//                imageName = "mastercard_icon.png"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/prepaidcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/prepaidcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 2, ")
//                ussql.append("'MasterCard',")
//                ussql.append("'mastercard.com', ")
//                ussql.append("'The MasterCard prepaid card may be used anywhere online!', ")
//                ussql.append("'Come join the MasterCard family and use this card worldwide!', ")
//                // Confirmation Description:
//                ussql.append(" 'prepaid card to will be sent to {email}.  Use this prepaid card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null, ")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"FIS\" }'),")
//                break
//            case "Gift Card"?:
//
//                // This is our new imported list for gift cards...  Only charities have the icon image.  Gift cards only have a small and large logo.
//                // card 1
//                var imageName = "810-Amazon.png"
//                var smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                var largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Amazon',")
//                ussql.append("'amazon.com',")
//                ussql.append("'Amazon holds the world at your fingertips.',")
//                ussql.append("'Amazon is the largest onine retailer in the world.  Use your Amazon card here!',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":810}'),")
//
//                // card 2
//                imageName = "678-Target.png"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 2, ")
//                ussql.append("'Target',")
//                ussql.append("'target.com',")
//                ussql.append("'Target is the store with the big red dot.',")
//                ussql.append("'Target is a department store with a little bit of everything!',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":678}'),")
//
//                // card 3
//                imageName = "933-Thinkgeek.png"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 3, ")
//                ussql.append("'ThinkGeek',")
//                ussql.append("'thinkgeek.com',")
//                ussql.append("'Fun things for geeks',")
//                ussql.append("'Want to buy an amazing gift for a geek?  Get it here!',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":933}'),")
//
//                // card 4
//                imageName = "768-WholeFoods.png"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 4, ")
//                ussql.append("'Whole Foods',")
//                ussql.append("'wholefoods.com',")
//                ussql.append("'Want good food?',")
//                ussql.append("'Whole Foods provides a wholistic approach to feed.',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":768}'),")
//
//                // card 5
//                imageName = "1044-TheCheeseCakeFactory.jpg"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 5, ")
//                ussql.append("'The Cheesecake Factory',")
//                ussql.append("'thecheesecakefactory.com',")
//                ussql.append("'Want Cheesecake?',")
//                ussql.append("'The Cheesecake Factory creates cheesecake masterpieces!',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":1044}'),")
//
//                // card 6
//                imageName = "924-RubyTuesday.png"
//                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
//                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 6, ")
//                ussql.append("'Ruby Tuesday',")
//                ussql.append("'rubytuesday.com',")
//                ussql.append("'Eat here!',")
//                ussql.append("'Hungry on Tuesday?  Come here and join us for dinner.',")
//                // Confirmation Description:
//                ussql.append(" 'virtual gift card to {name} will be sent to {email}.  Use this gift card to shop online.', ")
//                ussql.append("'\(largeImage)','\(smallImage)', null,")
//                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":924}'),")
//
////                // card 7
////                imageName = "996-BurgerKing.png"
////                smallImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; smallImage.append("/options/giftcard/small/\(imageName)")
////                largeImage = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImage.append("/options/giftcard/large/\(imageName)")
////                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 6, ")
////                ussql.append("'Burger King',")
////                ussql.append("'bk.com',")
////                ussql.append("'The original HOME OF THE WHOPPER®',")
////                ussql.append("'The original HOME OF THE WHOPPER®, our commitment to premium ingredients, signature recipes, and family-friendly dining experiences is what has defined our brand for more than 50 successful years.',")
////                ussql.append("'\(largeImage)','\(smallImage)', null,")
////                ussql.append("50.00,0,true, '{\"vendor\" : \"OmniCard\", \"vendorId\":996}'),")
//
//                break
//            case "Donate"?:
//                // Donation 1
//                var imageName = "heifer_image.png"
//                var largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                var smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                var iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Heifer International',")
//                ussql.append("'heifer.org',")
//                ussql.append("'Heifer International works with communities to create income, empower women, care for the Earth, and ultimately end world hunger and poverty',")
//                ussql.append("'Heifer International’s mission is to end hunger and poverty while caring for the Earth. For more than 70 years, we have provided livestock and environmentally sound agricultural training to improve the lives of those who struggle daily for reliable sources of food and income. We currently work in 25 countries, including the United States, to help families and communities become self-reliant.',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)', '\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//                // card 2
//                imageName = "bgca_fayetteville.png"
//                smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 2, ")
//                ussql.append("'Boys and Girls Club of Fayetteville',")
//                ussql.append("'fayettevillekids.org',")
//                ussql.append("'We are a resource for families to improve the quality of their lives through the development of youth in a safe environment.',")
//                ussql.append("'The Donald W. Reynolds Boys & Girls Club is a non-profit 501 (C)(3) organization currently serving over 10,000 community members per year through memberships, special events, facility reservations and drop-in business. Formerly known as the Fayetteville Youth Center, the Club over 75 years of service to youth and families in the local community.',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)','\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//
//                // card 3
//                imageName = "casa_image.png"
//                smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 3, ")
//                ussql.append("'CASA of Northwest Arkansas',")
//                ussql.append("'nwacasa.org',")
//                ussql.append("'Court Appointed Special Advocates of Northwest Arkansas provides compassionate volunteers who advocate for abused and neglected children.',")
//                ussql.append("'In essence, Court Appointed Special Advocates of Northwest Arkansas recruits, trains, and supervises volunteers who provide one-on-one advocacy for abused children and their families. Our CASA volunteers assist children by stabilizing their lives and moving them through the foster care system. CASAs are responsible for assessing the needs of the victims, making referrals for services (counseling, speech/occupational/physical therapy, educational interventions, medical and dental care) and making sure the emotional and physical needs of children are being met while in care.',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)','\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//
//                // card 4
//                imageName = "dress_for_success_image.png"
//                smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 4, ")
//                ussql.append("'Dress for Success of NW Arkansas',")
//                ussql.append("'dfsnwa.org',")
//                ussql.append("'Dress for Success Northwest Arkansas helps empower women toward economic independence by providing a network of support, professional attire, and programs that help them thrive in work and in life.',")
//                ussql.append("'Dress for Success Northwest Arkansas helps empower women toward economic independence by providing a network of support, professional attire, and programs that help her secure employment, retain her job, grow her career, provide for her family and improve their lives.  We offer long-lasting solutions the enable women to break the cycle of poverty.',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)','\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//
//                // card 5
//                imageName = "kuaf_image.png"
//                smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 5, ")
//                ussql.append("'KUAF',")
//                ussql.append("'kuaf.com',")
//                ussql.append("'KUAF 91.3 FM is northwest and Western Arkansas’ NPR affiliate and listener-supported radio station. We serve a 14-county area, with a population of 600,000, with NPR news programming.',")
//                ussql.append("'KUAF is northwest and western Arkansas’ NPR affiliate and listener-supported radio station. Owned by the University of Arkansas, KUAF has grown from “The 10-Watt Wonder” in 1973 to the 100,000-watt station it is today. We’ve been this area’s NPR affiliate for 33 years and have changed and grown along with the region, while also holding tight to our roots. We serve a 14-county area, with a population of 600,000, with NPR news programming - news that is highly-researched and vetted and is presented with insight and civil conversation. In today’s political climate, this kind of news programming is more important now than ever before. But more than just news, KUAF is unique in our area as the sole public radio station – and is unique in the breadth and variety of local programming offered. KUAF produces or airs 10 locally-produced programs! Very few other stations of this size produce this much local content – from the Community Spotlight Series with Pete Hartman to local news casts every morning to our daily, news magazine Ozarks at Large,hosted by Kyle Kellams. With the explosive growth in population of our area, KUAF aims to serve not just as a source for news and entertainment, but also as an anchor and introduction to the culture of our region. From The Pickin’ Post, The Generic Blues Show, and Shades of Jazz, plus the hundreds of local events featured in public service announcements and performances of local favorites in the Firmin-Garner performance studio, KUAF reflects the community it serves. We have heard from many listeners new to the area, that listening to KUAF helped them get a better understanding of their new home – from the local news to cultural coverage to the spirit of philanthropy that makes Northwest Arkansas so outstanding.',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)','\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//
//                // card 6
//                imageName = "kendrick_fincher_image.png"
//                smImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; smImgUrl.append("/options/donate/small/\(imageName)")
//                largeImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; largeImgUrl.append("/options/donate/large/\(imageName)")
//                iconImgUrl = EnvironmentVariables.sharedInstance.ImageBaseURL!; iconImgUrl.append("/options/donate/icon/\(imageName)")
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 6, ")
//                ussql.append("'Kendrick Fincher Foundation',")
//                ussql.append("'kendrickfincher.org',")
//                ussql.append("'Mission: Promote proper hydration and prevent heat illness through education and supporting activities. Vision: Expand national awareness and education to save lives.',")
//                ussql.append("'Mission: Promote proper hydration and prevent heat illness through  education and supporting activities.  Vision: Expand national awareness and education to save lives.  Education and Supporting Activities: Be Smart. BeeHydrated! - Presentations to school aged children on the importance of proper hydration Beat the Heat - Presentations to athletes, coaches and parents on proper hydration and heat illness prevention Distribution of squeeze bottles and educational pamphlets to support our educational presentations Representation at health fairs to educate the public about our mission and activities Community involvement in support of our mission by providing “cool huts”—misting tents with free ice water—at various outdoor public events. Annual youth run in Rogers, AR, to reinforce our mission and help children and the community learn about the importance of proper hydration and physical fitness in a fun environment. Partnerships with other sports injury prevention and wellness organizations Web presence that allows for regional and national reach Developing education programs for all ages including senior adults and industrial workforce',")
//                // Confirmation Description:
//                ussql.append(" 'will be donated to {name}. Our partner Pure Charity will handle end of year tax receipts. Please check your email for confirmation of your donation.', ")
//                ussql.append("'\(largeImgUrl)','\(smImgUrl)', '\(iconImgUrl)',")
//                ussql.append("50.00,0,true, '{ \"vendor\" : \"PureCharity\" }'),")
//
//                break
//            case "Bucket Coin"?:
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Bucket Coin',")
//                ussql.append("'buckettechnologies.com',")
//                ussql.append("'BUX: Our Crypto Coin',")
//                ussql.append("'Jump into the Crypto world!  Buy you BUX today.',")
//                // Confirmation Description:
//                ussql.append(" null, ")
//                ussql.append(" null, null, null,")
//                ussql.append("50.00,0,true, '{ }'),")
//                break
//            default:
//                break
//
//            }
//        }
//
//        // remove the last comma from the groups
//        ussql.removeLast()
//
//        let tbl = CashoutOption()
//
//        var checkuser = "INSERT INTO \(schema).\(tbl.table()) "
//        checkuser.append("(created, createdby, group_id, form_id, display_order, ")
//        checkuser.append("name, website, description, long_description, confirmation_description, picture_url, sm_picture_url, icon_url, ")
//        checkuser.append("minimum, maximum, display, vendor_detail) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(ussql)
//
//        print("Adding cashout options: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//        checkuser.removeAll()
//        ussql.removeAll()
//
//        schema = singapore.code_alpha_2!.lowercased()
//
//        let sgcg = try? usa_cg.sqlRows("SELECT * FROM \(schema).cashout_group WHERE country_id = \(singapore.id!) ORDER BY display_order DESC ", params: [])
//        for i in sgcg! {
//            switch i.data.cashoutGroupDic.group_name {
//            case "TopUp":
//                // card 1
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'TopUp',")
//                ussql.append("'www.ezetop.com/countries/asia/singapore',")
//                ussql.append("'TopUp',")
//                ussql.append("'TopUp Your Account',")
//                // Confirmation Description:
//                ussql.append("null, ")
//                ussql.append("'','',")
//                ussql.append("50.00,0,true),")
//                break
//            case "Donate":
//                // card 1
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Donate',")
//                ussql.append("'',")
//                ussql.append("'Donate to the cause',")
//                ussql.append("'Help make the community strong and tdonate today!',")
//                // Confirmation Description:
//                ussql.append("null, ")
//                ussql.append("'','',")
//                ussql.append("50.00,0,true),")
//                break
//            case "Bucket Coin":
//                ussql.append(" ('\(created_time)','\(server_user)', \(i.data.id!), 1, 1, ")
//                ussql.append("'Bucket Coin',")
//                ussql.append("'buckettechnologies.com',")
//                ussql.append("'BUX: Our Crypto Coin',")
//                ussql.append("'Jump into the Crypto world!  Buy you BUX today.', ")
//                // Confirmation Description:
//                ussql.append("null, ")
//                ussql.append("null, null, ")
//                ussql.append("50.00, 0, true),")
//                break
//            default:
//                break
//
//            }
//        }
//
//        // remove the last comma from the groups
//        ussql.removeLast()
//
//        checkuser = "INSERT INTO \(schema).\(tbl.table()) "
//        checkuser.append("(created, createdby, group_id, form_id, display_order, ")
//        checkuser.append("name, website, description, long_description, confirmation_description, picture_url, sm_picture_url, ")
//        checkuser.append("minimum, maximum, display) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(ussql)
//
//        print("Adding cashout options: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
//
//    func addForms() {
//
//        let tbl = Form()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO us.\(tbl.table()) "
//        checkuser.append("(created, createdby, name, title) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','BUX Coin', 'BUX'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','US Open Loop', 'Prepaid Card'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','US Closed Loop', 'Gift Card'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','US Donation', 'Donate') ")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
//
//    func addFormFieldType() {
//
//        let tbl = FormFieldType()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO us.\(tbl.table()) "
//        checkuser.append("(created, createdby, name) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Checkbox'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Text'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Number'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','E-Mail'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Phone'), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Currency')")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addFormField() {
//
//        let tbl = FormField()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO us.\(tbl.table()) "
//        checkuser.append("(created, createdby, name, type_id, length, is_required, needs_confirmation) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Full Name', 2, 25, TRUE, FALSE), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Email Address', 4, 50, TRUE, TRUE), ")
//        checkuser.append(" ('\(created_time)','\(server_user)','Keep me updated with new offers!', 1, 1, FALSE, FALSE) ")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addFormFields() {
//
//        let tbl = FormFields()
//
//        let created_time = RMServiceClass.getNow()
//        let server_user = RMDefaultUserValues.user_server
//
//        var checkuser = "INSERT INTO us.\(tbl.table()) "
//        checkuser.append("(created, createdby, form_id, field_id, display_order) ")
//        checkuser.append(" VALUES ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 1, 1, 1), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 1, 2, 2), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 1, 3, 3), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 2, 1, 1), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 2, 2, 2), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 2, 3, 3), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 3, 1, 1), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 3, 2, 2), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 3, 3, 3), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 4, 1, 1), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 4, 2, 2), ")
//        checkuser.append(" ('\(created_time)','\(server_user)', 4, 3, 3) ")
//
//        print("Adding user: \(checkuser)")
//        _ = try? tbl.sqlRows(checkuser, params: [])
//
//    }
    
//    func addBucketUSRetailer() {
//
//        // create the US retailer for Bucket
//        let retailer = Retailer()
//        retailer.is_suspended = false
//        retailer.is_verified = true
//        retailer.name = "Bucket Technologies Retailer"
//        retailer.retailer_code = "BUCKET1".lowercased()
//        retailer.send_settlement_confirmation = true
//
//        let ret = try? retailer.saveWithCustomType(schemaIn: "us", nil)
//        if let r = ret?.first, let r_id = r.data.id {
//            retailer.id = r_id
//        }
//
//        // create the first address for the bucket retailer
//        let add1 = Address()
//        add1.address1 = "1342 Florida Ave NW"
//        add1.city = "Washington"
//        add1.state = "District Of Columbia"
//        add1.postal_code = "20009"
//        add1.country_id = Country.idWith("us")
//        add1.retailer_id = retailer.id
//        _ = try? add1.saveWithCustomType(schemaIn: "us", nil)
//
//        // now lets geocode the address
//        add1.geocodeAddress()
//
//
//        // give them a second address
//        // create the first address for the bucket retailer
//        let add2 = Address()
//        add2.address1 = "117 W 4TH ST"
//        add2.address2 = "STE 202B"
//        add2.city = "Santa Ana"
//        add2.state = "CA"
//        add2.postal_code = "92701"
//        add2.country_id = Country.idWith("us")
//        add2.retailer_id = retailer.id
//        _ = try? add2.saveWithCustomType(schemaIn: "us", nil)
//
//        // now lets geocode the address
//        add2.geocodeAddress()
//
//        // create the US Sample retailer for Bucket
//        let retailer_s = Retailer()
//        retailer_s.is_suspended = false
//        retailer_s.is_verified = true
//        retailer_s.name = "Bucket Technologies Retailer"
//        retailer_s.retailer_code = "BUCKET-S".lowercased()
//        retailer_s.send_settlement_confirmation = true
//
//        let ret_s = try? retailer_s.saveWithCustomType(schemaIn: "us", nil)
//        if let r = ret_s?.first, let r_id = r.data.id {
//            retailer_s.id = r_id
//        }
//
//        // create the first address for the bucket retailer
//        let add1_s = Address()
//        add1_s.address1 = "2303 14th St NW"
//        add1_s.city = "Washington"
//        add1_s.state = "District Of Columbia"
//        add1_s.postal_code = "20009"
//        add1_s.country_id = Country.idWith("us")
//        add1_s.retailer_id = retailer_s.id
//        _ = try? add1_s.saveWithCustomType(schemaIn: "us", nil)
//
//        // now lets geocode the address
//        add1_s.geocodeAddress()
//
//    }
    
//    func addCountryCodes() {
//        let tbl = Country()
//
//        print("Setting create_time")
//        let create_time = RMServiceClass.getNow()
//        print("Setting server_user")
//        let server_user = RMDefaultUserValues.user_server
//
//        var insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Afghanistan','4','AF','AFG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Åland Islands','248','AX','ALA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Albania','8','AL','ALB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Algeria','12','DZ','DZA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('American Samoa','16','AS','ASM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Andorra','20','AD','AND',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Angola','24','AO','AGO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Anguilla','660','AI','AIA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Antarctica','10','AQ','ATA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Antigua and Barbuda','28','AG','ATG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Argentina','32','AR','ARG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Armenia','51','AM','ARM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Aruba','533','AW','ABW',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Australia','36','AU','AUS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Austria','40','AT','AUT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Azerbaijan','31','AZ','AZE',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Bahamas','44','BS','BHS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bahrain','48','BH','BHR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bangladesh','50','BD','BGD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Barbados','52','BB','BRB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Belarus','112','BY','BLR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Belgium','56','BE','BEL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Belize','84','BZ','BLZ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Benin','204','BJ','BEN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bermuda','60','BM','BMU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bhutan','64','BT','BTN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bolivia (Plurinational State of)','68','BO','BOL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bonaire, Sint Eustatius and Saba','535','BQ','BES',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bosnia and Herzegovina','70','BA','BIH',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Botswana','72','BW','BWA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bouvet Island','74','BV','BVT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Brazil','76','BR','BRA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('British Indian Ocean Territory','86','IO','IOT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Brunei Darussalam','96','BN','BRN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Bulgaria','100','BG','BGR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Burkina Faso','854','BF','BFA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Burundi','108','BI','BDI',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Cabo Verde','132','CV','CPV',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cambodia','116','KH','KHM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cameroon','120','CM','CMR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Canada','124','CA','CAN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cayman Islands','136','KY','CYM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Central African Republic','140','CF','CAF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Chad','148','TD','TCD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Chile','152','CL','CHL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('China','156','CN','CHN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Christmas Island','162','CX','CXR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cocos (Keeling) Islands','166','CC','CCK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Colombia','170','CO','COL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Comoros','174','KM','COM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Congo','178','CG','COG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Congo (Democratic Republic of the)','180','CD','COD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cook Islands','184','CK','COK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Costa Rica','188','CR','CRI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Côte d Ivoire','384','CI','CIV',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Croatia','191','HR','HRV',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cuba','192','CU','CUB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Curaçao','531','CW','CUW',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Cyprus','196','CY','CYP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Czechia','203','CZ','CZE',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Denmark','208','DK','DNK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Djibouti','262','DJ','DJI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Dominica','212','DM','DMA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Dominican Republic','214','DO','DOM',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Ecuador','218','EC','ECU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Egypt','818','EG','EGY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('El Salvador','222','SV','SLV',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Equatorial Guinea','226','GQ','GNQ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Eritrea','232','ER','ERI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Estonia','233','EE','EST',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Eswatini','748','SZ','SWZ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Ethiopia','231','ET','ETH',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Falkland Islands (Malvinas)','238','FK','FLK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Faroe Islands','234','FO','FRO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Fiji','242','FJ','FJI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Finland','246','FI','FIN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('France','250','FR','FRA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('French Guiana','254','GF','GUF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('French Polynesia','258','PF','PYF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('French Southern Territories','260','TF','ATF',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Gabon','266','GA','GAB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Gambia','270','GM','GMB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Georgia','268','GE','GEO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Germany','276','DE','DEU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Ghana','288','GH','GHA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Gibraltar','292','GI','GIB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Greece','300','GR','GRC',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Greenland','304','GL','GRL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Grenada','308','GD','GRD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guadeloupe','312','GP','GLP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guam','316','GU','GUM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guatemala','320','GT','GTM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guernsey','831','GG','GGY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guinea','324','GN','GIN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guinea-Bissau','624','GW','GNB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Guyana','328','GY','GUY',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Haiti','332','HT','HTI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Heard Island and McDonald Islands','334','HM','HMD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Holy See','336','VA','VAT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Honduras','340','HN','HND',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Hong Kong','344','HK','HKG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Hungary','348','HU','HUN',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Iceland','352','IS','ISL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('India','356','IN','IND',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Indonesia','360','ID','IDN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Iran (Islamic Republic of)','364','IR','IRN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Iraq','368','IQ','IRQ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Ireland','372','IE','IRL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Isle of Man','833','IM','IMN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Israel','376','IL','ISR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Italy','380','IT','ITA',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Jamaica','388','JM','JAM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Japan','392','JP','JPN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Jersey','832','JE','JEY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Jordan','400','JO','JOR',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Kazakhstan','398','KZ','KAZ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Kenya','404','KE','KEN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Kiribati','296','KI','KIR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Korea (Democratic Peoples Republic of)','408','KP','PRK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Korea (Republic of)','410','KR','KOR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Kuwait','414','KW','KWT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Kyrgyzstan','417','KG','KGZ',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Lao Peoples Democratic Republic','418','LA','LAO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Latvia','428','LV','LVA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Lebanon','422','LB','LBN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Lesotho','426','LS','LSO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Liberia','430','LR','LBR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Libya','434','LY','LBY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Liechtenstein','438','LI','LIE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Lithuania','440','LT','LTU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Luxembourg','442','LU','LUX',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Macao','446','MO','MAC',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Macedonia (the former Yugoslav Republic of)','807','MK','MKD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Madagascar','450','MG','MDG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Malawi','454','MW','MWI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Malaysia','458','MY','MYS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Maldives','462','MV','MDV',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mali','466','ML','MLI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Malta','470','MT','MLT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Marshall Islands','584','MH','MHL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Martinique','474','MQ','MTQ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mauritania','478','MR','MRT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mauritius','480','MU','MUS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mayotte','175','YT','MYT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mexico','484','MX','MEX',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Micronesia (Federated States of)','583','FM','FSM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Moldova (Republic of)','498','MD','MDA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Monaco','492','MC','MCO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mongolia','496','MN','MNG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Montenegro','499','ME','MNE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Montserrat','500','MS','MSR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Morocco','504','MA','MAR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Mozambique','508','MZ','MOZ',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Myanmar','104','MM','MMR',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Namibia','516','NA','NAM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Nauru','520','NR','NRU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Nepal','524','NP','NPL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Netherlands','528','NL','NLD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('New Caledonia','540','NC','NCL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('New Zealand','554','NZ','NZL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Nicaragua','558','NI','NIC',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Niger','562','NE','NER',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Nigeria','566','NG','NGA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Niue','570','NU','NIU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Norfolk Island','574','NF','NFK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Northern Mariana Islands','580','MP','MNP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Norway','578','NO','NOR',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Oman','512','OM','OMN',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Pakistan','586','PK','PAK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Palau','585','PW','PLW',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Palestine, State of','275','PS','PSE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Panama','591','PA','PAN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Papua New Guinea','598','PG','PNG',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Paraguay','600','PY','PRY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Peru','604','PE','PER',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Philippines','608','PH','PHL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Pitcairn','612','PN','PCN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Poland','616','PL','POL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Portugal','620','PT','PRT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Puerto Rico','630','PR','PRI',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Qatar','634','QA','QAT',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Réunion','638','RE','REU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Romania','642','RO','ROU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Russian Federation','643','RU','RUS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Rwanda','646','RW','RWA',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Saint Barthélemy','652','BL','BLM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Helena, Ascension and Tristan da Cunha','654','SH','SHN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Kitts and Nevis','659','KN','KNA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Lucia','662','LC','LCA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Martin (French part)','663','MF','MAF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Pierre and Miquelon','666','PM','SPM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saint Vincent and the Grenadines','670','VC','VCT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Samoa','882','WS','WSM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('San Marino','674','SM','SMR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sao Tome and Principe','678','ST','STP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Saudi Arabia','682','SA','SAU',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Senegal','686','SN','SEN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Serbia','688','RS','SRB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Seychelles','690','SC','SYC',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sierra Leone','694','SL','SLE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Singapore','702','SG','SGP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sint Maarten (Dutch part)','534','SX','SXM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Slovakia','703','SK','SVK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Slovenia','705','SI','SVN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Solomon Islands','90','SB','SLB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Somalia','706','SO','SOM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('South Africa','710','ZA','ZAF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('South Georgia and the South Sandwich Islands','239','GS','SGS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('South Sudan','728','SS','SSD',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Spain','724','ES','ESP',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sri Lanka','144','LK','LKA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sudan','729','SD','SDN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Suriname','740','SR','SUR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Svalbard and Jan Mayen','744','SJ','SJM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Sweden','752','SE','SWE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Switzerland','756','CH','CHE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Syrian Arab Republic','760','SY','SYR',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Taiwan, Province of China','158','TW','TWN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tajikistan','762','TJ','TJK',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tanzania, United Republic of','834','TZ','TZA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Thailand','764','TH','THA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Timor-Leste','626','TL','TLS',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Togo','768','TG','TGO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tokelau','772','TK','TKL',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tonga','776','TO','TON',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Trinidad and Tobago','780','TT','TTO',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tunisia','788','TN','TUN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Turkey','792','TR','TUR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Turkmenistan','795','TM','TKM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Turks and Caicos Islands','796','TC','TCA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Tuvalu','798','TV','TUV',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Uganda','800','UG','UGA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Ukraine','804','UA','UKR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('United Arab Emirates','784','AE','ARE',\(create_time),'\(server_user)'),")
//        insertstatement.append("('United Kingdom of Great Britain and Northern Ireland','826','GB','GBR',\(create_time),'\(server_user)'),")
//        insertstatement.append("('United States of America','840','US','USA',\(create_time),'\(server_user)'),")
//        insertstatement.append("('United States Minor Outlying Islands','581','UM','UMI',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Uruguay','858','UY','URY',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Uzbekistan','860','UZ','UZB',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Vanuatu','548','VU','VUT',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Venezuela (Bolivarian Republic of)','862','VE','VEN',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Viet Nam','704','VN','VNM',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Virgin Islands (British)','92','VG','VGB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Virgin Islands (U.S.)','850','VI','VIR',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Wallis and Futuna','876','WF','WLF',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Western Sahara','732','EH','ESH',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Yemen','887','YE','YEM',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//        insertstatement = "INSERT INTO public.\(tbl.table())"
//        insertstatement.append(" (name,code_numeric,code_alpha_2,code_alpha_3,created,createdby) ")
//        insertstatement.append(" VALUES ")
//        insertstatement.append("('Zambia','894','ZM','ZMB',\(create_time),'\(server_user)'),")
//        insertstatement.append("('Zimbabwe','716','ZW','ZWE',\(create_time),'\(server_user)')")
//        do {
//            try tbl.sqlRows(insertstatement, params: [])
//            print("Inserted Countries: \(insertstatement)")
//        } catch {
//            print("Problem inserting countries: \(error)")
//            print("                        sql: \(insertstatement)")
//        }
//
//    }
}
