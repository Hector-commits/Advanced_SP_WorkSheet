report 78901 "Start/Expire Sales Prices AP"
{
    // version VEN01N

    Caption = 'Start/Expire Sales Prices';
    ProcessingOnly = true;

    dataset
    {
        dataitem("Sales Price Worksheet"; "Sales Price Worksheet")
        {
            DataItemTableView = SORTING("Starting Date", "Ending Date", "Sales Type", "Sales Code", "Currency Code", "Item No.", "Variant Code", "Unit of Measure Code", "Minimum Quantity")
                                ORDER(Ascending);
            UseTemporary = true;

            trigger OnAfterGetRecord()
            begin
                SalesPriceWorksheet.RESET;
                IF SalesPriceWorksheet.GET("Starting Date", "Ending Date", "Sales Type", "Sales Code", "Currency Code", "Item No.", "Variant Code", "Unit of Measure Code", "Minimum Quantity") THEN BEGIN
                    IF newStartingDate <> 0D THEN BEGIN
                        SalesPriceWorksheet."New Starting Date" := newStartingDate;
                        SalesPriceWorksheet.MODIFY(FALSE);
                    END;

                    SalesPriceWorksheet.CALCFIELDS("Sales Price Exist");
                    IF (expirationDate <> 0D) AND SalesPriceWorksheet."Sales Price Exist" THEN//Only expire those Sales Prices which actually exist
                      BEGIN
                        checkDateCorrection(expirationDate, SalesPriceWorksheet."Starting Date", FALSE);
                        SalesPriceWorksheet.RENAME(SalesPriceWorksheet."Starting Date",
                                                   expirationDate,
                                                   SalesPriceWorksheet."Sales Type",
                                                   SalesPriceWorksheet."Sales Code",
                                                   SalesPriceWorksheet."Currency Code",
                                                   SalesPriceWorksheet."Item No.",
                                                   SalesPriceWorksheet."Variant Code",
                                                   SalesPriceWorksheet."Unit of Measure Code",
                                                   SalesPriceWorksheet."Minimum Quantity");
                    END ELSE BEGIN
                        IF (newStartingDate <> 0D) AND NOT SalesPriceWorksheet."Sales Price Exist" THEN BEGIN
                            checkDateCorrection(SalesPriceWorksheet."Ending Date", newStartingDate, FALSE);
                            SalesPriceWorksheet.RENAME(newStartingDate,
                                       SalesPriceWorksheet."Ending Date",
                                       SalesPriceWorksheet."Sales Type",
                                       SalesPriceWorksheet."Sales Code",
                                       SalesPriceWorksheet."Currency Code",
                                       SalesPriceWorksheet."Item No.",
                                       SalesPriceWorksheet."Variant Code",
                                       SalesPriceWorksheet."Unit of Measure Code",
                                       SalesPriceWorksheet."Minimum Quantity");
                        END;
                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin
                checkDateCorrection(expirationDate, newStartingDate, TRUE)
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field(newStartingDate; newStartingDate)
                {
                    Caption = 'New Starting Date';
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        IF newStartingDate <> 0D THEN
                            expirationDate := CALCDATE('<-1D>', newStartingDate)
                        ELSE
                            expirationDate := 0D;
                    end;
                }
                field(expirationDate; expirationDate)
                {
                    Caption = 'Expiration date';
                    ShowMandatory = true;
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        SalesPriceWorksheet: Record "Sales Price Worksheet";
        newStartingDate: Date;
        expirationDate: Date;

    procedure getSalesPricesWorkSheetRecords(SalesPriceWorksheet: Record "Sales Price Worksheet")
    begin
        "Sales Price Worksheet".INIT;
        "Sales Price Worksheet" := SalesPriceWorksheet;
        "Sales Price Worksheet".INSERT;
    end;

    local procedure checkDateCorrection(expDate: Date; startDate: Date; onProcessing: Boolean)
    var
        datesMandatory: Label 'The field New Starting Date or Expiration Date are mandatory.';
        checkDatesOnProc: Label 'Starting date cannot be before expiration date (of the existing sales price).';
        checkDates: Label 'Starting date %1 cannot be after expiration date %2 for %3-%4-%5.';
    begin
        //Checks if the existing or incoming expiration date and Starting dates are allowed
        IF (expDate = 0D) AND (startDate = 0D) AND onProcessing THEN
            ERROR(datesMandatory);

        IF (startDate <> 0D) AND
           (expDate <> 0D) AND
           (startDate < expDate) AND
           onProcessing THEN
            ERROR(checkDatesOnProc);

        SalesPriceWorksheet.CALCFIELDS("Item Description");
        IF (startDate <> 0D) AND
           (expDate <> 0D) AND
           (startDate > expDate) AND
           NOT onProcessing THEN
            ERROR(checkDates, startDate, expDate, SalesPriceWorksheet."Sales Code", SalesPriceWorksheet."Item No.", SalesPriceWorksheet."Item Description");
    end;
}

