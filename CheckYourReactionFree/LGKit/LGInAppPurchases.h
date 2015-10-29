//
//  Created by Grigory Lutkov on 01.10.12.
//  Copyright (c) 2012 Grigory Lutkov. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface LGInAppPurchases : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProductsRequest   *productsRequest;
    BOOL                storeDoneLoading;
    UIAlertView         *progressAlert;
    NSMutableArray      *productsArray;
}

+ (LGInAppPurchases *)sharedManager;
- (void)requestProductData;
- (void)loadStore;
- (BOOL)storeLoaded;
- (BOOL)canMakePurchases;
- (void)restoreCompletedTransactions;
- (void)purchaseProduct:(NSString *)productId;
- (SKProduct *)getProduct:(NSString *)productId;

@end



@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end