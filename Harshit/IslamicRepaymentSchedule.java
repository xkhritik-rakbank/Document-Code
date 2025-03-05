package com.kunal;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class IslamicRepaymentSchedule {
	public static void main(String[] args) {
		Document document = new Document(PageSize.A4.rotate());
		document.setMargins(15, 15, 147, 65);
		
		try {
			PdfWriter writer = PdfWriter.getInstance(document,
					new FileOutputStream("C:/Users/harshit.rai/Desktop/New folder/RepaySch.pdf"));
			int prevPage=0;
			writer.setPageEvent(new PdfPageEventHelper() {
				
				@Override
				public void onEndPage(PdfWriter writer, Document document) {
				    try {
				    	
				    	int currentPage=writer.getCurrentPageNumber();
				    	if (currentPage ==1) {
				    					        // Header Image
				        Image headerLeftImage = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/islamicHeader.png");
				        //Image headerRightImage = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/rightLogo.jpg");
				        headerLeftImage.scaleToFit(150, 50);
				        //headerRightImage.scaleToFit(150, 50);

				        headerLeftImage.scalePercent(65, 65);
				        headerLeftImage.setAbsolutePosition(document.getPageSize().getLeft() + 20,
				                document.getPageSize().getTop() - 135);//120

				        writer.getDirectContent().addImage(headerLeftImage);

				        // Footer Image
				        Image footerCenterImage1 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer1.jpg");
				        Image footerCenterImage2 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer2.jpg");
				        footerCenterImage1.scalePercent(40, 40);
				        footerCenterImage2.scalePercent(40, 40);

				        float totalWidth = footerCenterImage1.getScaledWidth() + footerCenterImage2.getScaledWidth() + 20;
				        float startX = (document.getPageSize().getWidth() - totalWidth) / 2;

				        footerCenterImage1.setAbsolutePosition(startX, 15);
				        footerCenterImage2.setAbsolutePosition(startX + footerCenterImage1.getScaledWidth() + 20, 15);

				        writer.getDirectContent().addImage(footerCenterImage1);
				        writer.getDirectContent().addImage(footerCenterImage2);

				        PdfContentByte cb = writer.getDirectContent();
				        Font pageFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
				        Phrase pageNo = new Phrase("Page " + writer.getPageNumber(), pageFont);
				        ColumnText.showTextAligned(cb, Element.ALIGN_LEFT, pageNo, document.left(), document.bottom()-15, 0);
				      
				    	}
				        // Add table header from page 2 onwards
				        if (currentPage>(1)) {
				        	//document.setMargins(15, 15, 150, 65);
				        	Image headerLeftImage1 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/islamicHeader.png");
					        //Image headerRightImage1 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/rightLogo.jpg");
					        headerLeftImage1.scaleToFit(150, 50);
					        //headerRightImage1.scaleToFit(150, 50);

					        headerLeftImage1.scalePercent(60, 55);//65  60
					        headerLeftImage1.setAbsolutePosition(document.getPageSize().getLeft() + 20,
					                document.getPageSize().getTop() - 110);//88
					        headerLeftImage1.setBottom(0);
					        
					        writer.getDirectContent().addImage(headerLeftImage1);
					        
				        	
				            PdfPTable table = new PdfPTable(14);
				            table.setTotalWidth(document.getPageSize().getWidth() - document.leftMargin() - document.rightMargin());
				            table.setLockedWidth(true);

				            // Set relative widths for columns
				            //float[] columnWidths = new float[]{8, 8, 10, 9, 8, 8, 8, 8, 8, 10, 7, 6, 10, 10};
				            float[] columnWidths = new float[]{10, 10, 10, 10, 10, 9, 11, 10, 10, 11, 9, 9, 11, 10};
				            table.setWidths(columnWidths);
				            
				            String[] headers = { "SI No,", "Due Date", "Opening Principal", "Monthly Commitment", "Principal Amount", "Profit Amount", 
				            		"Fee", "Deferred Profit", "Moratorium Profit", "Closing Principal", "Profit Rate", "Total Payable", "Received Amount",
				                    "Life Takaful Amount(TI)" };
				            
				            PdfPCell lineCell1 = new PdfPCell(new Phrase("_".repeat(121)));
				            lineCell1.setColspan(headers.length);
				            lineCell1.setBorder(PdfPCell.NO_BORDER);
				            lineCell1.setHorizontalAlignment(Element.ALIGN_CENTER);
				            lineCell1.setPaddingTop(-9);
				            lineCell1.setPaddingBottom(2);
				            table.addCell(lineCell1);
				            
				            

				            Font headerFont = FontFactory.getFont(FontFactory.HELVETICA, 9);//9
				            for (String header : headers) {
				                PdfPCell cell = new PdfPCell(new Phrase(header, headerFont));
				                cell.setHorizontalAlignment(Element.ALIGN_CENTER);
				                cell.setBorder(Rectangle.NO_BORDER);
				                cell.setPadding(3f);
				                table.addCell(cell);
				            }

				            // Add line below headers
				            PdfPCell lineCell = new PdfPCell(new Phrase("_".repeat(121)));
				            lineCell.setColspan(headers.length);
				            lineCell.setBorder(PdfPCell.NO_BORDER);
				            lineCell.setHorizontalAlignment(Element.ALIGN_CENTER);
				            lineCell.setPaddingTop(-9);
				            lineCell.setPaddingBottom(12);//10
				            table.addCell(lineCell);

				            // Position the table just below the header image
				            PdfContentByte cb = writer.getDirectContent();
				            float yPosition = document.getPageSize().getTop() - 110; // Adjusted position 110
				            table.writeSelectedRows(0, -1, document.leftMargin(), yPosition, cb);
				            
				            // Footer Image
					        Image footerCenterImage1 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer1.jpg");
					        Image footerCenterImage2 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer2.jpg");
					        footerCenterImage1.scalePercent(40, 40);
					        footerCenterImage2.scalePercent(40, 40);

					        float totalWidth = footerCenterImage1.getScaledWidth() + footerCenterImage2.getScaledWidth() + 20;
					        float startX = (document.getPageSize().getWidth() - totalWidth) / 2;

					        footerCenterImage1.setAbsolutePosition(startX, 15);
					        footerCenterImage2.setAbsolutePosition(startX + footerCenterImage1.getScaledWidth() + 20, 15);

					        writer.getDirectContent().addImage(footerCenterImage1);
					        writer.getDirectContent().addImage(footerCenterImage2);
					        
					        PdfContentByte cb1 = writer.getDirectContent();
					        Font pageFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
					        Phrase pageNo = new Phrase("Page " + writer.getPageNumber(), pageFont);
					        ColumnText.showTextAligned(cb1, Element.ALIGN_LEFT, pageNo, document.left(), document.bottom()-15, 0);
				        }

				    } catch (DocumentException | IOException e) {
				        e.printStackTrace();
				    }
				}
			});

			document.open();

			// Title Table starts
            PdfPTable titleSection = new PdfPTable(2);
            titleSection.setWidthPercentage(100);
            titleSection.setWidths(new float[]{60, 40}); 


            Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
            PdfPCell titleCell = new PdfPCell(new Paragraph("Repayment Schedule", titleFont));
            titleCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            titleCell.setBorder(Rectangle.NO_BORDER);
            titleCell.setPaddingBottom(0);
            titleSection.addCell(titleCell);
            
            SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
            String currentDate = dateFormat.format(new Date());
            Font dateFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
            PdfPCell dateCell = new PdfPCell(new Paragraph("Date: " + currentDate, dateFont));
            dateCell.setHorizontalAlignment(Element.ALIGN_LEFT);
            dateCell.setBorder(Rectangle.NO_BORDER);
            
            titleSection.addCell(dateCell);
            titleSection.setSpacingAfter(-7f);
            titleSection.setSpacingBefore(-5f);
            document.add(titleSection);
			// Title Table ends
            
            String line = "_";
            int linelength  = 80;
            while(linelength>0) {
            	line+="_";
            	linelength--;
            }
            
			document.add(new Paragraph(new Phrase(line)));

			// Customer Data Table
			PdfPTable customerTable = new PdfPTable(5);
			customerTable.setWidthPercentage(60);
			customerTable.setSplitRows(true);
			customerTable.setSpacingBefore(3f);
			customerTable.setWidths(new float[] {1,1,2.5f,1,1});

			// Define all the column labels and their corresponding data
			String[][] customerData = { {"Agreement No.:", "AG123456", "Agreement Date:", "25/12/2025"},
					{"Customer Name:", "BEKHAITI SAEED SAYAH SAEED ALMANSORI", "Frequency:", "Monthly" },
					{ "Product: ", "Personal Finance", "Effective Rate: ", "8.15%" },
					{ "Finance Amount: ", "138,000.00", "Balance Tenor: ", "48" },
					{ "Currency: ", "AED","",""} };

			// Add all rows to the table
			for (String[] row : customerData) {
				addCustomerDataCell(customerTable, row[0], row[1], row[2], row[3]);
			}

			customerTable.setHorizontalAlignment(Element.ALIGN_LEFT);
			customerTable.getDefaultCell().setBorder(Rectangle.NO_BORDER);
			document.add(customerTable);

			// Loan Data Table
			PdfPTable table = new PdfPTable(14);
			table.setWidthPercentage(100);

			document.add(new Paragraph(new Phrase("_".repeat(121))));

			String[] headers = { "SI No,", "Due Date", "Opening Principal", "Monthly Commitment", "Principal Amount", "Profit Amount", 
            		"Fee", "Deferred Profit", "Moratorium Profit", "Closing Principal", "Profit Rate", "Total Payable", "Received Amount",
            "Life Takaful Amount(TI)" };

			for (String header : headers) {
				addHeaderCell(table, header);
			}

			PdfPCell lineCell = new PdfPCell(new Phrase("_".repeat(121)));
			lineCell.setColspan(headers.length);
			lineCell.setBorder(PdfPCell.NO_BORDER);
			lineCell.setHorizontalAlignment(Element.ALIGN_CENTER);
			lineCell.setPaddingTop(-7);
			lineCell.setPaddingBottom(10);
			table.addCell(lineCell);

			for (int i = 1; i <= 48; i++) {
				addRow(table, String.valueOf(i), "20/07/2026", "43,508.36", "1,760.00", "1,330.88", "429.12", "0.00", "23.89", "1760",
						"42,177.48", "12.00", "30", "0.00", "");
			}

			table.getDefaultCell().setBorder(Rectangle.NO_BORDER);
			table.setSpacingBefore(7f);
			document.add(table);

			document.add(new Paragraph(new Phrase("_".repeat(121))));

			PdfPTable endTable = new PdfPTable(14);
			endTable.setWidthPercentage(100);
			endTable.setSpacingBefore(5f);

			addRow(endTable, "", "", "Total:", "1,760.00", "1,330.88", "429.12", "0.00", "", "1760", "", "", "", "",
					"");

			endTable.setSpacingAfter(-12f);
			document.add(endTable);
			document.add(new Paragraph(new Phrase("_".repeat(121))));

			document.close();
			System.out.println("PDF created successfully.");
		} catch (FileNotFoundException | DocumentException e) {
			e.printStackTrace();
		}
	}

	private static void addHeaderCell(PdfPTable table, String headerText) {
		Font headerFont = FontFactory.getFont(FontFactory.HELVETICA, 9.5f);
		PdfPCell headerCell = new PdfPCell(new Paragraph(headerText, headerFont));
		headerCell.setHorizontalAlignment(Element.ALIGN_CENTER);
		headerCell.setBorder(Rectangle.NO_BORDER);
		table.addCell(headerCell);
	}

	// Modified method to handle column-data pairs
	private static void addCustomerDataCell(PdfPTable table, String label1, String value1, String label2,
			String value2) {
		Font customerFont = FontFactory.getFont(FontFactory.HELVETICA, 9);

		// First
		PdfPCell labelCell1 = new PdfPCell(new Paragraph(label1, customerFont));
		labelCell1.setBorder(Rectangle.NO_BORDER);
		labelCell1.setHorizontalAlignment(Element.ALIGN_LEFT);
		table.addCell(labelCell1);

		PdfPCell valueCell1 = new PdfPCell(new Paragraph(value1, customerFont));
		valueCell1.setBorder(Rectangle.NO_BORDER);
		valueCell1.setHorizontalAlignment(Element.ALIGN_CENTER);
		valueCell1.setPaddingRight(-200f);
		table.addCell(valueCell1);
		//
		
		//Blank Cell
		PdfPCell blankCell = new PdfPCell(new Paragraph("                                      ", customerFont));
		blankCell.setBorder(Rectangle.NO_BORDER);
		blankCell.setPaddingLeft(50f);
		table.addCell(blankCell);
		//
		
		// Second
		PdfPCell labelCell2 = new PdfPCell(new Paragraph(label2, customerFont));
		labelCell2.setBorder(Rectangle.NO_BORDER);
		labelCell2.setHorizontalAlignment(Element.ALIGN_LEFT);
		table.addCell(labelCell2);

		PdfPCell valueCell2 = new PdfPCell(new Paragraph(value2, customerFont));
		valueCell2.setBorder(Rectangle.NO_BORDER);
		valueCell2.setHorizontalAlignment(Element.ALIGN_CENTER);
		table.addCell(valueCell2);
		//
	}

	private static void addRow(PdfPTable table, String... rowData) {
		Font cellFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
		for (String data : rowData) {
			PdfPCell cell = new PdfPCell(new Paragraph(data, cellFont));
			cell.setBorder(Rectangle.NO_BORDER);
			cell.setHorizontalAlignment(Element.ALIGN_CENTER);
			table.addCell(cell);
		}
	}

}
