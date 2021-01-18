pageextension 78900 "Sales Price Worksheet AP" extends "Sales Price Worksheet"
{

    PromotedActionCategories = 'New,Process,Report,Prices';


    layout
    {
        addfirst(Control1)
        {
            field("Open Prices Date"; "Open Prices Date")
            {
                ApplicationArea = All;
                Visible = false;
            }
            field("New Starting Date"; "New Starting Date")
            {
                ApplicationArea = All;
            }
        }
        modify("Item Description")
        {
            ApplicationArea = All;
            Visible = true;
        }
        addafter("Item Description")
        {
            field("Item Description 2"; "Item Description 2")
            {
                ApplicationArea = All;
            }
            field("Purch. Unit of Measure"; "Purch. Unit of Measure")
            {
                ApplicationArea = All;
            }
            field("Purchase Price Date"; "Purchase Price Date")
            {
                ApplicationArea = All;
            }
            field("Purchase Price"; "Purchase Price")
            {
                ApplicationArea = All;
                StyleExpr = StyleExprPurchasePrice;
            }
            field("Unit Cost"; "Unit Cost")
            {
                ApplicationArea = All;
                StyleExpr = StyleExprUnitCost;
            }
            field("Vendor No."; "Vendor No.")
            {
                ApplicationArea = All;
            }
            field(Margin; Margin)
            {
                ApplicationArea = All;
            }
            field("New Price Calculation"; "New Price Calculation")
            {
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.UPDATE;
                end;
            }
        }
        addafter("New Unit Price")
        {
            field("Sales Price Exist"; "Sales Price Exist")
            {
            }
        }
    }

    actions
    {

        modify("Suggest &Item Price on Wksh.")
        {
            Visible = false;
        }
        modify("Suggest &Sales Price on Wksh.")
        {
            Visible = false;
        }
        addafter("I&mplement Price Change")
        {
            action(customSuggestPrice)
            {
                Caption = 'Suggest customer price group';
                Image = SuggestSalesPrice;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Report "Suggest Cust. Price Group AP";
            }
            action(expireSalesPrices)
            {
                Caption = 'Start/Expire Sales Prices';
                Image = DueDate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    SalesPriceWorksheet: Record "Sales Price Worksheet";
                    ExpireSalesPrices: Report "Start/Expire Sales Prices AP";
                begin
                    SalesPriceWorksheet.RESET;
                    SalesPriceWorksheet.COPYFILTERS(Rec);
                    CurrPage.SETSELECTIONFILTER(SalesPriceWorksheet);
                    IF SalesPriceWorksheet.FINDSET THEN
                        REPEAT
                            ExpireSalesPrices.getSalesPricesWorkSheetRecords(SalesPriceWorksheet);
                        UNTIL SalesPriceWorksheet.NEXT = 0;

                    ExpireSalesPrices.RUNMODAL();

                    CurrPage.UPDATE();
                end;
            }
        }
        addlast(Navigation)
        {
            group(Prices)
            {
                Caption = 'Prices';
                action(Sales_Prices)
                {
                    Caption = 'Sales Prices';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Sales Prices";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                }
                action("Purchase Prices")
                {
                    Caption = 'Purchase Prices';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Purchase Prices";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                }
                action("Line Discounts Purchases")
                {
                    Caption = 'Line Discounts Purchases';
                    Image = LineDiscount;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Purchase Line Discounts";
                    RunPageLink = "Item No." = FIELD("Item No.");
                    RunPageView = SORTING("Item No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        updateStyleExpr();
    end;

    var
        StyleExprPurchasePrice: Text;
        StyleExprUnitCost: Text;

    local procedure updateStyleExpr()
    begin
        StyleExprPurchasePrice := 'Standard';
        StyleExprUnitCost := 'Standard';

        IF "New Price Calculation" = "New Price Calculation"::"Purchase Price" THEN
            StyleExprPurchasePrice := 'Strong';

        IF "New Price Calculation" = "New Price Calculation"::"Unit Cost" THEN
            StyleExprUnitCost := 'Strong';
    end;
}

