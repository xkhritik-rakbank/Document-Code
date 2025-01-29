package com.kunal;

import com.itextpdf.text.*;
import com.itextpdf.text.pdf.*;

import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Date;

public class LoanRepaymentSchedule {
	public static void main(String[] args) {
		Document document = new Document(PageSize.A4.rotate());
		document.setMargins(15, 15, 85, 65);

		try {
			PdfWriter writer = PdfWriter.getInstance(document,
					new FileOutputStream("C:/Users/harshit.rai/Desktop/New folder/RepaySch.pdf"));

			writer.setPageEvent(new PdfPageEventHelper() {
				@Override
				public void onEndPage(PdfWriter writer, Document document) {
					try {
						// Header Image
						Image headerLeftImage = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/header.png");
						Image headerRightImage = Image
								.getInstance("C:/Users/harshit.rai/Desktop/New folder/rightLogo.jpg");
						headerLeftImage.scaleToFit(150, 50);
						headerRightImage.scaleToFit(150, 50);

						headerLeftImage.scalePercent(65, 55);
						headerLeftImage.setAbsolutePosition(document.getPageSize().getLeft() + 20,
								document.getPageSize().getTop() - 88);
						// headerRightImage.setAbsolutePosition(document.getPageSize().getWidth() -
						// headerRightImage.getScaledWidth() - 15,document.getPageSize().getHeight() -
						// 50);

						writer.getDirectContent().addImage(headerLeftImage);
						// writer.getDirectContent().addImage(headerRightImage);

						// Footer Image
						Image footerCenterImage1 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer1.jpg");
						Image footerCenterImage2 = Image.getInstance("C:/Users/harshit.rai/Desktop/New folder/footer2.jpg");
						footerCenterImage1.scalePercent(40, 40);
						footerCenterImage2.scalePercent(40, 40);

						float totalWidth = footerCenterImage1.getScaledWidth() + footerCenterImage2.getScaledWidth()
								+ 20;
						float startX = (document.getPageSize().getWidth() - totalWidth) / 2;

						footerCenterImage1.setAbsolutePosition(startX, 15);
						footerCenterImage2.setAbsolutePosition(startX + footerCenterImage1.getScaledWidth() + 20, 15);

						writer.getDirectContent().addImage(footerCenterImage1);
						writer.getDirectContent().addImage(footerCenterImage2);
						
						PdfContentByte cb = writer.getDirectContent();
						Font pageFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10);
						Phrase pageNo = new Phrase("Page "+ writer.getPageNumber(), pageFont);
						ColumnText.showTextAligned(cb, Element.ALIGN_LEFT, pageNo, document.left(), document.bottom()-15, 0);
						
						
						
						
//						PdfPTable titleSection = new PdfPTable(2);
//						titleSection.setTotalWidth(540);
//						titleSection.setWidths(new float[] { 60, 40 });
//						titleSection.setLockedWidth(true);
//
//						Font titleFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 11);
//						PdfPCell titleCell = new PdfPCell(new Paragraph("Repayment Schedule", titleFont));
//						titleCell.setHorizontalAlignment(Element.ALIGN_LEFT);
//						titleCell.setBorder(Rectangle.NO_BORDER);
//						titleCell.setPaddingBottom(0);
//						titleSection.addCell(titleCell);
//
//						SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy");
//						String currentDate = dateFormat.format(new Date());
//						Font dateFont = FontFactory.getFont(FontFactory.HELVETICA, 9);
//						PdfPCell dateCell = new PdfPCell(new Paragraph("Date: " + currentDate, dateFont));
//						dateCell.setHorizontalAlignment(Element.ALIGN_LEFT);
//						dateCell.setBorder(Rectangle.NO_BORDER);
//						titleSection.addCell(dateCell);
//						
//						PdfContentByte cb = writer.getDirectContent();
//						// Draw titleSection below header
//						titleSection.writeSelectedRows(0, -2, document.leftMargin(), document.top(), cb);

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
            document.add(titleSection);
			// Title Table ends

			document.add(new Paragraph(new Phrase("_".repeat(81))));

			// Customer Data Table
			PdfPTable customerTable = new PdfPTable(4);
			customerTable.setWidthPercentage(60);
			customerTable.setSpacingBefore(3f);

			// Define all the column labels and their corresponding data
			String[][] customerData = { { "Customer Name:", "John Doe", "Agreement No.:", "AG123456" },
					{ "Loan Amount:", "50,000", "Tenure:", "48 months" },
					{ "Interest Rate:", "12%", "EMI Amount:", "1,760" },
					{ "Start Date:", "20/07/2023", "End Date:", "20/07/2026" } };

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

			String[] headers = { "Instl. Num", "Due Date", "Opening Principal", "Instl. Amount", "Principal",
					"Interest", "LI Amount", "PI Amount", "EMI", "CL.Principal", "Rate", "Days", "Deferral Flag",
					"Moratorium Interest" };

			for (String header : headers) {
				addHeaderCell(table, header);
			}

			PdfPCell lineCell = new PdfPCell(new Phrase("_".repeat(121)));
			lineCell.setColspan(headers.length);
			lineCell.setBorder(PdfPCell.NO_BORDER);
			lineCell.setHorizontalAlignment(Element.ALIGN_CENTER);
			lineCell.setPaddingTop(-8);
			lineCell.setPaddingBottom(10);
			table.addCell(lineCell);

			for (int i = 0; i < 48; i++) {
				addRow(table, "1", "20/07/2026", "43,508.36", "1,760.00", "1,330.88", "429.12", "0.00", "23.89", "1760",
						"42,177.48", "12.00", "30", "", "0.00");
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
		Font headerFont = FontFactory.getFont(FontFactory.HELVETICA, 10);
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
		table.addCell(valueCell1);
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
