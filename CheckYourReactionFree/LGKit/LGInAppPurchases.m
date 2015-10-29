//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import "LGInAppPurchases.h"
#import "LGLocalization.h"
#import "LGKit.h"
#import "LGReachability.h"

@implementation LGInAppPurchases

//Singleton instance
static LGInAppPurchases *_sharedManager = nil;

#pragma mark - Singleton Methods

+ (LGInAppPurchases *)sharedManager
{
	@synchronized([LGInAppPurchases class])
	{
		if (!_sharedManager) _sharedManager = [[self alloc] init];
        
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

+ (id)alloc
{
	@synchronized([LGInAppPurchases class])
	{
		NSAssert(_sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
		_sharedManager = [super alloc];
		return _sharedManager;
	}
	// to avoid compiler warning
	return nil;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"LGInAppPurchases: Initialising...");
        
        storeDoneLoading = NO;
        productsArray = [NSMutableArray new];
        
        [self loadStore];
    }
	return self;
}

#pragma mark - Init Methods

// call this method once on startup
- (void)loadStore
{
    // restarts any purchases if they were interrupted last time the app was open
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    // get the product description (defined in early sections)
    [self requestProductData];
}

- (BOOL)storeLoaded
{
    if (storeDoneLoading) NSLog(@"LGInAppPurchases: Store is Loaded");
    else
    {
        NSLog(@"LGInAppPurchases: Store is not Loaded");
        
        [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_connectionError", nil)
                                    message:LGLocalizedString(@"MCIAP_tryAgainMessage", nil)
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
	return storeDoneLoading;
}

// call this before making a purchase
- (BOOL)canMakePurchases
{
    if ([SKPaymentQueue canMakePayments])
    {
        NSLog(@"LGInAppPurchases: Purchasing Enabled");
    }
    else
    {
        NSLog(@"LGInAppPurchases: Purchasing Disabled");
        
        [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchasingDisabled", nil)
                                    message:LGLocalizedString(@"MCIAP_parentalControl", nil)
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
    
    int internetStatus = kInternetStatus;
    if (!internetStatus) [kLGKit createAlertNoInternet];
    
    return ([SKPaymentQueue canMakePayments] && internetStatus);
}

// kick off the upgrade transaction
- (void)purchaseProduct:(NSString *)productId
{
    SKPayment *payment = [SKPayment paymentWithProduct:[self getProduct:productId]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
    progressAlert = [kLGKit createProgressAlertWithActivity:YES
                                                      title:LGLocalizedString(@"MCIAP_progressAlertTitle", nil)
                                                    message:LGLocalizedString(@"MCIAP_progressAlertMessage", nil)
                                                   delegate:self
                                          cancelButtonTitle:nil
                                           otherButtonTitle:nil];
}

// Restore completed transactions
- (void)restoreCompletedTransactions
{
	[[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - In-App Product Accessor Methods

- (SKProduct *)getProduct:(NSString *)productId
{
    SKProduct *product;
	
	for (int i=0; i < productsArray.count; i++)
	{
		product = [productsArray objectAtIndex:i];
        
        if ([product.productIdentifier isEqualToString:productId]) break;
        else product = nil;
	}
    
    return product;
}

+ (NSMutableArray *)allProductsId
{
    NSMutableArray *productsIdArray = [NSMutableArray array];
    NSArray *consumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Consumables"];
    NSArray *nonConsumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Non-Consumables"];
    
    [productsIdArray addObjectsFromArray:consumables];
    [productsIdArray addObjectsFromArray:nonConsumables];
    
    return productsIdArray;
}

#pragma mark - Product Data

+ (NSDictionary *)getItemsDictionary
{
    return [NSDictionary dictionaryWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"LGInAppPurchases.plist"]];
}

- (void)requestProductData
{
    NSMutableArray *productsIdArray = [NSMutableArray array];
    NSArray *consumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Consumables"];
    NSArray *nonConsumables = [[LGInAppPurchases getItemsDictionary] objectForKey:@"Non-Consumables"];
    
    [productsIdArray addObjectsFromArray:consumables];
    [productsIdArray addObjectsFromArray:nonConsumables];
    
	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:productsIdArray]];
	productsRequest.delegate = self;
	[productsRequest start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSArray *purchasableObjects = response.products;
    
    //NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
    //NSUInteger baseLength = [baseString length];
	
	for (int i=0; i < purchasableObjects.count; i++)
	{
		SKProduct *product = [purchasableObjects objectAtIndex:i];
        [productsArray addObject:product];
        
        NSString *localizedTitleString = [NSString stringWithFormat:@"%@", [product localizedTitle]];
        NSString *priceString = [NSString stringWithFormat:@"%.2f", [[product price] doubleValue]];
        //NSString *productIdentifierShortString = [NSString stringWithFormat:@"%@", [[product productIdentifier] substringFromIndex:baseLength]];
        NSString *productIdentifierFullString = [NSString stringWithFormat:@"%@", [product productIdentifier]];
        
		NSLog(@"Product: %@|  Price: %@|  ID: %@",
              [localizedTitleString stringByAppendingString:[@"                              " substringFromIndex:[localizedTitleString length]]],
              [priceString stringByAppendingString:[@"               " substringFromIndex:[priceString length]]],
              [productIdentifierFullString stringByAppendingString:[@"                                                                      " substringFromIndex:[productIdentifierFullString length]]]);
	}
    
    storeDoneLoading = YES;
    
    for (NSString *invalidProductId in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product id: %@" , invalidProductId);
        
        storeDoneLoading = YES;
    }
}

#pragma mark - Transaction Methods

// called when the transaction status is updated
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}

// called when the transaction was successful
- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"MCInAppPurcahses: Transaction Complete...");
    [self recordTransaction:transaction];
    [self provideContent:transaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has been restored and successfully completed
- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"MCInAppPurcahses: Transaction Restore...");
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction.originalTransaction.payment.productIdentifier];
    [self finishTransaction:transaction wasSuccessful:YES];
}

// called when a transaction has failed
- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"MCInAppPurcahses: Transaction Failed... Reason: %@", transaction.error.localizedDescription);
        
        // error
        [self finishTransaction:transaction wasSuccessful:NO];
    }
    else
    {
        NSLog(@"MCInAppPurcahses: User Cancelled Transaction");
        
        // this is fine, the user just cancelled, so don’t notify
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    }
}

// saves a record of the transaction by storing the receipt to disk
- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
    NSMutableArray *productsIdArray = [LGInAppPurchases allProductsId];
	
	for (int i=0; i < [productsIdArray count]; i++)
	{
		NSString *product = [productsIdArray objectAtIndex:i];
        
        if ([transaction.payment.productIdentifier isEqualToString:product])
        {
            NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
            NSUInteger baseLength = [baseString length];
            
            // save the transaction receipt to disk
            [[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt
                                                     forKey:[NSString stringWithFormat:@"%@TransactionReceipt", [product substringFromIndex:baseLength]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"LGInAppPurchases: recordTransaction: %@ forKey: %@", transaction.payment.productIdentifier, [NSString stringWithFormat:@"%@TransactionReceipt", [product substringFromIndex:baseLength]]);
            
            break;
        }
	}
}

// enable features
- (void)provideContent:(NSString *)productId
{
    NSMutableArray *productsIdArray = [LGInAppPurchases allProductsId];
	
	for (int i=0; i < [productsIdArray count]; i++)
	{
		NSString *product = [productsIdArray objectAtIndex:i];
        
        if ([productId isEqualToString:product])
        {
            NSString *baseString = [[LGInAppPurchases getItemsDictionary] objectForKey:@"BaseFeatureIdString"];
            NSUInteger baseLength = [baseString length];
            
            // enable the requested features by setting a global user value
            [[NSUserDefaults standardUserDefaults] setBool:YES
                                                    forKey:[NSString stringWithFormat:@"is%@Purchased", [product substringFromIndex:baseLength]]];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSLog(@"LGInAppPurchases: provideContent: %@ forKey: %@", productId, [NSString stringWithFormat:@"is%@Purchased", [product substringFromIndex:baseLength]]);
            
            break;
        }
	}
}

// removes the transaction from the queue and posts a notification with the transaction result
- (void)finishTransaction:(SKPaymentTransaction *)transaction wasSuccessful:(BOOL)wasSuccessful
{
    // remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    if (wasSuccessful)
    {
        NSString *product = transaction.payment.productIdentifier;
        
        if ([product rangeOfString:@"RemoveAds"].length == 9)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseRemoveAdsMessage", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate25"].length == 8)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseDonate25Message", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate10"].length == 8)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseDonate10Message", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate1"].length == 7)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseDonate1Message", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate3"].length == 7)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseDonate3Message", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        else if ([product rangeOfString:@"Donate5"].length == 7)
            [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchaseSuccessfulTitle", nil)
                                        message:LGLocalizedString(@"MCIAP_purchaseDonate5Message", nil)
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:LGLocalizedString(@"MCIAP_purchasingError", nil)
                                    message:[NSString stringWithFormat:@"%@.\n%@", transaction.error.localizedDescription, LGLocalizedString(@"MCIAP_tryAgainMessage", nil)]
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

@end


#pragma mark - SKProduct (LocalizedPrice)


@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end