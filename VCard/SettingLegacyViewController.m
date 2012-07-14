//
//  SettingAppInfoViewController.m
//  VCard
//
//  Created by 王 紫川 on 12-7-12.
//  Copyright (c) 2012年 Mondev. All rights reserved.
//

#import "SettingLegacyViewController.h"

@interface SettingLegacyViewController ()

@end

@implementation SettingLegacyViewController

@synthesize textView = _textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"版权";
    
    self.textView.text = @"	VCard HD 受著作权法及国际著作权条约和其它知识产权法及条约的保护。未经许可不得出售,不得用于任何商业目的的活动之中。否则我们将追究相关法律责任。\n\n1. 许可证的授予 \n	本《版权声明》授予下列权利安装和使用;可安装无限制数量的产品来使用。复制、分发和传播;可以复制、分发和传播无限制数量的产品,但必须保证每⼀份复制、分发和传播都必须是完整和真实的,包括所有有关产品的软件、电子文档, 版权和商标宣言,亦包括本协议。软件可以独立分发亦可随同其他软件⼀起分发,但如因此而引起任何问题,版权人将不予承担任何责任。\n\n2. 其它权利和限制说明\n	禁止反向工程、反向编译和反向汇编;不得对产品进行反向工程、反向编译和反向汇编,同时不得改动编译在程序文件内 部的任何资源。除非适用法律明文允许上述活动,否则必须遵守此协议限制。组件的分隔:这些软件产品分别是被当成⼀个单⼀产品而被授予许可使用,不得将各个部分分开用于任何目的行动。\n\n3. 软件产品转让\n	在不保留任何副本,可以将本“软件产品”(包括所有组成部分零件、媒介和印刷材料、任何更新版本、本《版权声明》等)全部转让,并且受让人接受本《版权声明》的各项条件下,可永久转让在本《版权声明》下的所有权利。 如果产品为更新本,转让时必须包括所有前版本。\n\n4. 终止\n	如未遵守本《版权声明》的各项条件,在不损害其它权利的情况下,版权人可将本《版权声明》终止。 如发生此种情况, 则必须销毁产品和各部分的所有副本以及由其衍生、创建出的其他版本和产品。\n\n	VCard HD 的设计(包括但不限于产品中所含的任何图象、照片、动画、文字和附加程序)、随附的印刷材料、及产品的 任何副本的一切所有权和知识产权,均由版权人拥有。 通过使用产品可访问的内容的一切所有权和知识产权均属于各自内容的所有者拥有并可能受适用著作权或其它知识产权法律和条约的保护。本《版权声明》不授予您使用这些内容的权利。包括上述对于产品本身更改或处置的条约,任何抄袭、伪造或其他侵权行为将受到法律范围内的最大起诉。";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Dispose of any resources that can be recreated.
    self.textView = nil;
}


@end
