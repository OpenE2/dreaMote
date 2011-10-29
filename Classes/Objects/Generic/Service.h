//
//  Service.h
//  dreaMote
//
//  Created by Moritz Venn on 08.03.08.
//  Copyright 2008-2011 Moritz Venn. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ServiceProtocol.h"

/*!
 @brief Generic Service.
 */
@interface GenericService : NSObject <ServiceProtocol>
{
@private
	NSString *_sref; /*!< @brief Reference. */
	NSString *_sname; /*!< @brief Name. */
	BOOL _valid; /*!< @brief Valid service?. */
	/* Picons */
	BOOL _calculatedPicon; /*!< @brief Did we try to load the picon before? */
	UIImage *_picon; /*!< @brief Picon. */
	NSString *_piconName; /*!< @brief Name for Picon. */
}

/*!
 @brief Init with existing Service.

 @note Required to create a Copy.
 @return Service instance.
 */
- (id)initWithService:(NSObject<ServiceProtocol> *)service;

/*!
 @brief Set valid status.

 @param newValid
 */
- (void)setValid:(BOOL)newValid;

@end
